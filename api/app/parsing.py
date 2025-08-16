import fitz, hashlib, io, logging
from minio import Minio
from .settings import settings
from .ocr import enhance_pdf_text_blocks, is_ocr_available

logger = logging.getLogger(__name__)

def _minio():
    host = settings.minio_endpoint.replace("http://","").replace("https://","")
    return Minio(host,
                 access_key=settings.minio_access_key,
                 secret_key=settings.minio_secret_key,
                 secure=settings.minio_endpoint.startswith("https"))

def _ensure_bucket(m, bucket):
    if not m.bucket_exists(bucket):
        m.make_bucket(bucket)

def _put(m, bucket, key, data: bytes, content_type: str):
    _ensure_bucket(m, bucket)
    m.put_object(bucket, key, io.BytesIO(data), len(data), content_type=content_type)
    return f"{settings.minio_endpoint}/{bucket}/{key}"

def parse_pdf_to_sections(pdf_bytes: bytes, doc_name: str, doc_id: str):
    m = _minio()
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    pages, images = [], []
    
    # Check if OCR is available for enhanced text extraction
    ocr_available = is_ocr_available()
    if ocr_available:
        logger.info("OCR preprocessing available - will enhance text extraction")
    else:
        logger.info("OCR preprocessing not available - using standard PyMuPDF extraction")
    
    for pno in range(doc.page_count):
        page = doc.load_page(pno)
        blocks = page.get_text("blocks")
        text_blocks = []
        for b in blocks:
            if len(b) >= 5 and b[4].strip():
                text_blocks.append({"bbox": b[:4], "text": b[4].strip()})
        
        # Get page image for OCR enhancement if available
        page_image_bytes = None
        if ocr_available and text_blocks:  # Only do OCR if we have some text to potentially enhance
            try:
                # Render page as image for OCR
                pix = page.get_pixmap(matrix=fitz.Matrix(2.0, 2.0))  # 2x scaling for better OCR
                page_image_bytes = pix.tobytes("png")
                logger.info(f"Rendered page {pno+1} for OCR enhancement")
            except Exception as e:
                logger.warning(f"Failed to render page {pno+1} for OCR: {e}")
        
        # Enhance text blocks with OCR if available
        if page_image_bytes:
            try:
                text_blocks = enhance_pdf_text_blocks(text_blocks, page_image_bytes)
                logger.info(f"Enhanced page {pno+1} text blocks with OCR")
            except Exception as e:
                logger.warning(f"OCR enhancement failed for page {pno+1}: {e}")
        
        # Extract images from page
        for img in page.get_images(full=True):
            xref = img[0]
            pix = fitz.Pixmap(doc, xref)
            if pix.alpha: pix = fitz.Pixmap(pix, 0)
            img_bytes = pix.tobytes("png")
            sha = hashlib.sha256(img_bytes).hexdigest()[:16]
            key = f"{doc_id}/page_{pno+1}/{sha}.png"
            url = _put(m, settings.minio_bucket, key, img_bytes, "image/png")
            images.append({"doc_id": doc_id, "page": pno+1, "url": url})
        
        pages.append({"page": pno+1, "text_blocks": text_blocks})
        logger.info(f"Processed page {pno+1}: {len(text_blocks)} text blocks")
    
    doc.close()
    
    total_blocks = sum(len(p["text_blocks"]) for p in pages)
    logger.info(f"Completed parsing {doc_name}: {len(pages)} pages, {total_blocks} text blocks, {len(images)} images")
    
    return {"doc_id": doc_id, "title": doc_name, "pages": pages, "images": images}
