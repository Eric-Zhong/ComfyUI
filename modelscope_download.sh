#!/bin/bash

download_model() {
    local model_name="$1"
    local file_path="$2"
    local local_dir="$3"
    
    local file_name=$(basename "$file_path")
    local target_file="${local_dir}${file_name}"
    local downloaded_file="${local_dir}${file_path}"

    echo "file_name: ${file_name}"
    echo "target_file: ${target_file}"
    echo "local_dir: ${local_dir}"
    echo "downloaded_file: ${downloaded_file}"
    local parent_dir=$(dirname "$downloaded_file")
    echo "parent_dir: ${parent_dir}"
    
    if [ -f "$target_file" ]; then
        echo "文件已存在，跳过下载: $target_file"
        return 0
    fi
    
    echo "开始下载: $file_name"
    if modelscope download --model "$model_name" "$file_path" --local_dir "$local_dir"; then
        if [ -f "$downloaded_file" ]; then
            mv "$downloaded_file" "$target_file"
            # TODO: 这里有问题，它会把./models 下目录全给删除了，没研究为什么。
            # 删除下载目录下的空文件夹
            # while [ "$parent_dir" != "$local_dir" ] && [ "$parent_dir" != "." ]; do
            #     rm -rf "$parent_dir" 2>/dev/null || true
            #     parent_dir=$(dirname "$parent_dir")
            # done
            echo "下载完成: $target_file"
        else
            echo "警告: 下载文件未找到: $downloaded_file"
        fi
    else
        echo "下载失败: $file_name"
        return 1
    fi
}


download_model "junweifeng/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "umt5_xxl_fp8_e4m3fn_scaled.safetensors" "./models/text_encoders/"

WAN_MODEL="Comfy-Org/Wan_2.2_ComfyUI_Repackaged"
# 下载Wan_2.2 i2v模型
download_model "$WAN_MODEL" "split_files/vae/wan_2.1_vae.safetensors" "./models/vae/"
download_model "$WAN_MODEL" "split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" "./models/diffusion_models/"
download_model "$WAN_MODEL" "split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" "./models/diffusion_models/"
download_model "$WAN_MODEL" "split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" "./models/loras/"
download_model "$WAN_MODEL" "split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" "./models/loras/"
# 下载Wan_2.2 t2v模型
download_model "$WAN_MODEL" "split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors" "./models/diffusion_models/"
download_model "$WAN_MODEL" "split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors" "./models/diffusion_models/"
download_model "$WAN_MODEL" "split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors" "./models/loras/"
download_model "$WAN_MODEL" "split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors" "./models/loras/"

# https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors
download_model "xiangzi666/clip_vision_h.safetensors" "clip_vision_h.safetensors" "./models/clip_vision/"
# https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_fun_camera_v1.1_1.3B_bf16.safetensors
# download_model "$WAN_MODEL" "esolve/main/split_files/diffusion_models/wan2.1_fun_camera_v1.1_1.3B_bf16.safetensors" "./models/diffusion_models/"

# LTX-2 / T2V
LTX2_MODEL="Lightricks/LTX-2"
download_model "$LTX2_MODEL" "ltx-2-19b-distilled.safetensors" "./models/checkpoints/"
download_model "$LTX2_MODEL" "ltx-2-19b-dev-fp8.safetensors" "./models/checkpoints/"
download_model "$LTX2_MODEL" "ltx-2-19b-distilled-lora-384.safetensors" "./models/loras/"
download_model "$LTX2_MODEL" "lgemma_3_12B_it_fp4_mixed.safetensors" "./models/checkpoints/"
download_model "$LTX2_MODEL" "ltx-2-spatial-upscaler-x2-1.0.safetensors" "./models/latent_upscale_models/"

LTX2_LORA_MODEL="Lightricks/LTX-2-19b-IC-LoRA-Depth-Control"
download_model "$LTX2_LORA_MODEL" "ltx-2-19b-ic-lora-depth-control.safetensors" "./models/loras/"

COMFY_UI_LOTUS_MODEL="Comfy-Org/lotus"
download_model "$COMFY_UI_LOTUS_MODEL" "lotus-depth-d-v1-1.safetensors" "./models/diffusion_models/"

COMFY_UI_LTX_MODEL="Comfy-Org/ltx-2"
# https://www.modelscope.cn/models/Comfy-Org/ltx-2/file/view/master/split_files%2Ftext_encoders%2Fgemma_3_12B_it_fp4_mixed.safetensors?status=2
download_model "$COMFY_UI_LTX_MODEL" "split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors" "./models/text_encoders/"

SD_VAE_FT_MSE="stabilityai/sd-vae-ft-mse-original"
download_model "$SD_VAE_FT_MSE" "vae-ft-mse-840000-ema-pruned.safetensors" "./models/vae/"

MODEL_SCOPE_NAME="Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-Left"
download_model "$MODEL_SCOPE_NAME" "ltx-2-19b-lora-camera-control-dolly-left.safetensors" "./models/loras/"


