import io, logging
from typing import List, Dict, Any, Optional
from PIL import Image
import torch
from transformers import TrOCRProcessor, VisionEncoderDecoderModel
from .settings import settings

logger = logging.getLogger(__name__)

# Global variables for lazy loading
_ocr_model = None
_ocr_processor = None

def _get_ocr_model():
    """Initialize and return the TrOCR model for lightweight OCR"""
    global _ocr_model, _ocr_processor
    if _ocr_model is None or _ocr_processor is None:
        try:
            # Use TrOCR for lightweight OCR instead of heavy dots.ocr
            model_name = "microsoft/trocr-base-printed"  # Lightweight printed text OCR
            logger.info(f"Loading lightweight OCR model: {model_name}")
            _ocr_processor = TrOCRProcessor.from_pretrained(model_name)
            _ocr_model = VisionEncoderDecoderModel.from_pretrained(model_name)
            
            # Move to appropriate device
            if torch.cuda.is_available():
                _ocr_model = _ocr_model.to("cuda")
                _ocr_model = _ocr_model.half()  # Use FP16 for faster inference
            
            logger.info("Lightweight OCR model loaded successfully")
        except Exception as e:
            logger.error(f"Failed to load OCR model: {e}")
            # Fallback: return None to indicate OCR is not available
            _ocr_model = None
            _ocr_processor = None
            return None, None
    return _ocr_model, _ocr_processor

def extract_text_from_image(image_bytes: bytes) -> Optional[str]:
    """
    Extract text from an image using TrOCR model
    
    Args:
        image_bytes: Raw image bytes
        
    Returns:
        Extracted text content or None if extraction fails
    """
    try:
        # Get model and processor
        model, processor = _get_ocr_model()
        if model is None or processor is None:
            logger.warning("OCR model not available, skipping OCR extraction")
            return None
        
        # Load image
        image = Image.open(io.BytesIO(image_bytes))
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Process the image with TrOCR (no text prompt needed)
        pixel_values = processor(image, return_tensors="pt").pixel_values
        
        # Move inputs to the same device as model
        device = next(model.parameters()).device
        pixel_values = pixel_values.to(device)
        
        # Generate text with TrOCR
        with torch.no_grad():
            generated_ids = model.generate(pixel_values, max_new_tokens=512)
        
        # Decode the generated text
        generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
        
        logger.info(f"Successfully extracted {len(generated_text)} characters via TrOCR")
        return generated_text.strip() if generated_text else None
        
    except Exception as e:
        logger.error(f"Error extracting text from image: {e}")
        return None

def parse_document_page(image_bytes: bytes) -> Dict[str, Any]:
    """
    Parse document page using TrOCR for text extraction
    
    Args:
        image_bytes: Raw image bytes of document page
        
    Returns:
        Dictionary containing structured document information
    """
    try:
        # Use the same TrOCR extraction as the simple function
        extracted_text = extract_text_from_image(image_bytes)
        
        if extracted_text:
            logger.info(f"Successfully parsed document page: {len(extracted_text)} characters")
            return {
                "text": extracted_text,
                "structure_type": "basic_ocr",
                "extraction_method": "trocr"
            }
        else:
            return {
                "text": "",
                "structure_type": "no_text_found",
                "extraction_method": "trocr"
            }
        
    except Exception as e:
        logger.error(f"Error parsing document page: {e}")
        return {
            "text": "",
            "structure_type": "error",
            "extraction_method": "trocr",
            "error": str(e)
        }

def enhance_pdf_text_blocks(text_blocks: List[Dict[str, Any]], page_image_bytes: Optional[bytes] = None) -> List[Dict[str, Any]]:
    """
    Enhance PDF text blocks with OCR when available
    
    Args:
        text_blocks: List of text block dictionaries from PyMuPDF
        page_image_bytes: Optional page image bytes for OCR enhancement
        
    Returns:
        Enhanced text blocks with improved OCR text when available
    """
    enhanced_blocks = []
    
    # If we have a page image, try OCR parsing first
    ocr_text = None
    if page_image_bytes:
        ocr_result = parse_document_page(page_image_bytes)
        if ocr_result.get("text") and ocr_result["structure_type"] != "error":
            ocr_text = ocr_result["text"]
    
    # Process each text block
    for block in text_blocks:
        enhanced_block = block.copy()
        
        # If OCR text is available and significantly longer than extracted text, use OCR
        original_text = block.get("text", "")
        if ocr_text and len(ocr_text) > len(original_text) * 1.2:  # OCR text is 20% longer
            enhanced_block["text"] = ocr_text
            enhanced_block["enhanced_with_ocr"] = True
            enhanced_block["original_text"] = original_text
            logger.info("Enhanced text block with comprehensive OCR parsing")
            
            # Use OCR text for all blocks on this page (since it's comprehensive)
            break
        else:
            enhanced_block["enhanced_with_ocr"] = False
        
        enhanced_blocks.append(enhanced_block)
    
    # If we used comprehensive OCR, replace all blocks with a single comprehensive block
    if ocr_text and any(block.get("enhanced_with_ocr") for block in enhanced_blocks):
        return [{
            "bbox": [0, 0, 1, 1],  # Full page bbox
            "text": ocr_text,
            "enhanced_with_ocr": True,
            "extraction_method": "dots_ocr_comprehensive"
        }]
    
    return enhanced_blocks

def is_ocr_available() -> bool:
    """Check if OCR functionality is available"""
    try:
        model, processor = _get_ocr_model()
        return model is not None and processor is not None
    except:
        return False
