#!/usr/bin/env python3
"""
MedraN Medical AI Assistant - Mobile Model Converter
Converts language models to mobile-optimized formats using MLC-LLM
"""

import argparse
import os
import sys
import json
import subprocess
from pathlib import Path
from typing import Optional, Dict, Any

class MobileModelConverter:
    """Converts models for mobile deployment using MLC-LLM"""
    
    def __init__(self, base_dir: str = None):
        if base_dir is None:
            base_dir = Path(__file__).parent.parent
        self.base_dir = Path(base_dir)
        self.converted_dir = self.base_dir / "converted"
        self.temp_dir = self.base_dir / "temp"
        
        # Ensure directories exist
        self.converted_dir.mkdir(exist_ok=True)
        self.temp_dir.mkdir(exist_ok=True)
    
    def get_model_config(self, model_name: str) -> Dict[str, Any]:
        """Get optimized config for specific model architectures"""
        configs = {
            "llama": {
                "quantization": "q4f16_1",
                "context_window_size": 2048,
                "prefill_chunk_size": 1024,
            },
            "gemma": {
                "quantization": "q4f16_1", 
                "context_window_size": 2048,
                "prefill_chunk_size": 1024,
            },
            "phi": {
                "quantization": "q4f16_1",
                "context_window_size": 2048,
                "prefill_chunk_size": 512,
            },
            "qwen": {
                "quantization": "q4f16_1",
                "context_window_size": 2048,
                "prefill_chunk_size": 1024,
            },
            "default": {
                "quantization": "q4f16_1",
                "context_window_size": 2048,
                "prefill_chunk_size": 1024,
            }
        }
        
        # Detect model type from name
        model_lower = model_name.lower()
        for model_type in configs:
            if model_type in model_lower:
                return configs[model_type]
        
        return configs["default"]
    
    def convert_model(self, 
                     model_path: str, 
                     output_name: str = None,
                     target_platform: str = "android",
                     quantization: str = None) -> bool:
        """Convert a model to mobile format"""
        
        print(f"🔄 Converting model: {model_path}")
        print(f"📱 Target platform: {target_platform}")
        
        if output_name is None:
            output_name = Path(model_path).name.replace("/", "_")
        
        output_dir = self.converted_dir / output_name
        
        # Get model-specific config
        config = self.get_model_config(model_path)
        if quantization:
            config["quantization"] = quantization
        
        print(f"⚙️ Using config: {config}")
        
        try:
            # Step 1: Generate config
            print("📝 Generating model config...")
            config_cmd = [
                "mlc_llm", "gen_config",
                model_path,
                "--quantization", config["quantization"],
                "--context-window-size", str(config["context_window_size"]),
                "--prefill-chunk-size", str(config["prefill_chunk_size"]),
                "--output", str(output_dir / "mlc-chat-config.json")
            ]
            
            result = subprocess.run(config_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"❌ Config generation failed: {result.stderr}")
                return False
            
            # Step 2: Convert weights  
            print("⚖️ Converting model weights...")
            weight_cmd = [
                "mlc_llm", "convert_weight",
                model_path,
                "--quantization", config["quantization"],
                "--output", str(output_dir)
            ]
            
            result = subprocess.run(weight_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"❌ Weight conversion failed: {result.stderr}")
                return False
            
            # Step 3: Compile for target platform
            print(f"🔨 Compiling for {target_platform}...")
            compile_cmd = [
                "mlc_llm", "compile",
                str(output_dir / "mlc-chat-config.json"),
                "--device", target_platform,
                "--output", str(output_dir / f"model-{target_platform}.so")
            ]
            
            result = subprocess.run(compile_cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"❌ Compilation failed: {result.stderr}")
                return False
            
            # Create deployment info
            deployment_info = {
                "model_name": output_name,
                "source_model": model_path,
                "target_platform": target_platform,
                "quantization": config["quantization"],
                "context_window": config["context_window_size"],
                "prefill_chunk_size": config["prefill_chunk_size"],
                "output_dir": str(output_dir),
                "files": {
                    "config": "mlc-chat-config.json",
                    "weights": f"params_shard_*.bin",
                    "library": f"model-{target_platform}.so"
                }
            }
            
            with open(output_dir / "deployment_info.json", "w") as f:
                json.dump(deployment_info, f, indent=2)
            
            print(f"✅ Model conversion completed!")
            print(f"📁 Output directory: {output_dir}")
            print(f"📋 Deployment info saved to: {output_dir}/deployment_info.json")
            
            return True
            
        except Exception as e:
            print(f"❌ Conversion failed with error: {e}")
            return False
    
    def list_converted_models(self):
        """List all converted models"""
        print("📱 Converted Mobile Models:")
        print("-" * 50)
        
        if not list(self.converted_dir.iterdir()):
            print("No converted models found.")
            return
        
        for model_dir in self.converted_dir.iterdir():
            if model_dir.is_dir():
                info_file = model_dir / "deployment_info.json"
                if info_file.exists():
                    with open(info_file) as f:
                        info = json.load(f)
                    print(f"📱 {info['model_name']}")
                    print(f"   Source: {info['source_model']}")
                    print(f"   Platform: {info['target_platform']}")
                    print(f"   Quantization: {info['quantization']}")
                    print(f"   Context: {info['context_window']}")
                    print()
                else:
                    print(f"📱 {model_dir.name} (no info available)")
    
    def cleanup_temp(self):
        """Clean up temporary files"""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
        self.temp_dir.mkdir(exist_ok=True)
        print("🧹 Temporary files cleaned up.")

def main():
    parser = argparse.ArgumentParser(description="Convert models for mobile deployment")
    parser.add_argument("command", choices=["convert", "list", "cleanup"], 
                       help="Command to execute")
    parser.add_argument("--model", help="Model path or name to convert")
    parser.add_argument("--output", help="Output name for converted model")
    parser.add_argument("--platform", default="android", 
                       choices=["android", "ios", "opencl", "vulkan"],
                       help="Target platform")
    parser.add_argument("--quantization", 
                       choices=["q4f16_1", "q4f32_1", "q8f16_1", "q0f16", "q0f32"],
                       help="Quantization method")
    
    args = parser.parse_args()
    
    converter = MobileModelConverter()
    
    if args.command == "convert":
        if not args.model:
            print("❌ Model path is required for conversion")
            sys.exit(1)
        
        success = converter.convert_model(
            model_path=args.model,
            output_name=args.output,
            target_platform=args.platform,
            quantization=args.quantization
        )
        
        if not success:
            sys.exit(1)
            
    elif args.command == "list":
        converter.list_converted_models()
        
    elif args.command == "cleanup":
        converter.cleanup_temp()

if __name__ == "__main__":
    main()
