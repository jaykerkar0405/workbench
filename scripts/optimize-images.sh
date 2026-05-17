#!/bin/bash

# ============================================================================
# Image Optimization Script for Portfolio
# ============================================================================
# Optimizes and resizes images for web performance
# - Icons: PNG format, lossless compression, max 512px
# - Screenshots/Images: JPG format, max 1920px width, 85% quality
# ============================================================================

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Configuration
PROJECTS_DIR="src/lib/assets/projects"
HACKATHONS_DIR="src/lib/assets/hackathons"

# Image optimization settings
PNG_QUALITY=90
PNG_COMPRESSION=9
JPG_QUALITY=85
MAX_WIDTH=1920
MAX_ICON_SIZE=512

# Threshold: Skip if file was already optimized (less than 2% potential savings)
OPTIMIZATION_THRESHOLD=2

# Counters
TOTAL_FILES=0
OPTIMIZED_FILES=0
CONVERTED_FILES=0
RESIZED_FILES=0
SKIPPED_FILES=0
FAILED_FILES=0
TOTAL_ORIGINAL_SIZE=0
TOTAL_NEW_SIZE=0

# Check dependencies
if ! command -v magick &> /dev/null; then
    echo -e "${RED}Error: ImageMagick is not installed${NC}"
    echo "Install: sudo apt install imagemagick"
    exit 1
fi

# Header
clear
echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}          Image Optimization for Portfolio${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

VERSION=$(magick -version | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
echo -e "${DIM}Using ImageMagick ${VERSION}${NC}"
echo ""

# Function to format file size
format_size() {
    local size=$1
    if [ $size -ge 1048576 ]; then
        awk "BEGIN {printf \"%.2f MB\", $size / 1048576}"
    else
        awk "BEGIN {printf \"%.0f KB\", $size / 1024}"
    fi
}

# Function to get file size in bytes
get_file_size() {
    local file="$1"
    if [ -f "$file" ]; then
        stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Function to check if file is an icon
is_icon() {
    local filename=$(basename "$1")
    [[ "$filename" == "icon.png" ]] || [[ "$filename" == "icon.jpg" ]] || [[ "$filename" == "icon.jpeg" ]]
}

# Function to get image dimensions
get_dimensions() {
    local file="$1"
    magick identify -format "%wx%h" "$file" 2>/dev/null || echo "0x0"
}

# Function to optimize image
optimize_image() {
    local file="$1"
    local filename=$(basename "$file")
    local dirname=$(dirname "$file")
    local extension="${filename##*.}"
    local basename="${filename%.*}"
    
    # Get original size and dimensions
    local original_size=$(get_file_size "$file")
    local dimensions=$(get_dimensions "$file")
    TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + original_size))
    
    local output_file="$file"
    local temp_file="${dirname}/.${basename}_temp.tmp"
    local was_resized=false
    local was_converted=false
    
    if is_icon "$file"; then
        # ============================================================
        # ICONS: PNG format, resize if too large, lossless compression
        # ============================================================
        output_file="${dirname}/${basename}.png"
        
        local width=$(echo $dimensions | cut -d'x' -f1)
        local height=$(echo $dimensions | cut -d'x' -f2)
        
        if [ $width -gt $MAX_ICON_SIZE ] || [ $height -gt $MAX_ICON_SIZE ]; then
            magick "$file" -resize "${MAX_ICON_SIZE}x${MAX_ICON_SIZE}>" -strip -quality $PNG_QUALITY \
                -define png:compression-level=$PNG_COMPRESSION "$temp_file" 2>/dev/null
            was_resized=true
        else
            magick "$file" -strip -quality $PNG_QUALITY \
                -define png:compression-level=$PNG_COMPRESSION "$temp_file" 2>/dev/null
        fi
        
        if [ $? -eq 0 ] && [ -f "$temp_file" ]; then
            local new_size=$(get_file_size "$temp_file")
            local new_dimensions=$(get_dimensions "$temp_file")
            
            # Calculate potential savings
            local potential_savings=$(awk "BEGIN {printf \"%.1f\", (($original_size - $new_size) / $original_size) * 100}")
            local savings_int=$(awk "BEGIN {printf \"%.0f\", $potential_savings}")
            
            # Only optimize if savings are significant or format needs conversion
            if [ $savings_int -ge $OPTIMIZATION_THRESHOLD ] || [ "$file" != "$output_file" ]; then
                [ "$file" != "$output_file" ] && rm -f "$file" && was_converted=true
                mv "$temp_file" "$output_file"
                
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + new_size))
                
                local original_fmt=$(format_size $original_size)
                local new_fmt=$(format_size $new_size)
                
                printf "  ${GREEN}✓${NC} %-30s ${DIM}%9s → %-9s${NC} ${GREEN}(%4.1f%%)${NC}" "$filename" "$original_fmt" "$new_fmt" "$potential_savings"
                
                if [ "$was_converted" = true ]; then
                    printf " ${YELLOW}[PNG]${NC}"
                    CONVERTED_FILES=$((CONVERTED_FILES + 1))
                fi
                if [ "$was_resized" = true ]; then
                    printf " ${BLUE}[${new_dimensions}]${NC}"
                    RESIZED_FILES=$((RESIZED_FILES + 1))
                fi
                echo ""
                OPTIMIZED_FILES=$((OPTIMIZED_FILES + 1))
            else
                rm -f "$temp_file"
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
                printf "  ${DIM}− %-30s${NC} ${DIM}Already optimal${NC}\n" "$filename"
                SKIPPED_FILES=$((SKIPPED_FILES + 1))
            fi
        else
            rm -f "$temp_file"
            printf "  ${RED}✗ %-30s Failed${NC}\n" "$filename"
            FAILED_FILES=$((FAILED_FILES + 1))
            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
        fi
        
    elif [[ "$filename" == screenshot-* ]] || [[ "$filename" == image-* ]]; then
        # ============================================================
        # SCREENSHOTS/IMAGES: JPG format, resize to max width, compress
        # ============================================================
        output_file="${dirname}/${basename}.jpg"
        
        local width=$(echo $dimensions | cut -d'x' -f1)
        
        if [ $width -gt $MAX_WIDTH ]; then
            magick "$file" -resize "${MAX_WIDTH}x>" -strip -quality $JPG_QUALITY \
                -sampling-factor 4:2:0 -interlace Plane -colorspace RGB "$temp_file" 2>/dev/null
            was_resized=true
        else
            magick "$file" -strip -quality $JPG_QUALITY \
                -sampling-factor 4:2:0 -interlace Plane -colorspace RGB "$temp_file" 2>/dev/null
        fi
        
        if [ $? -eq 0 ] && [ -f "$temp_file" ]; then
            local new_size=$(get_file_size "$temp_file")
            local new_dimensions=$(get_dimensions "$temp_file")
            
            # Calculate potential savings
            local potential_savings=$(awk "BEGIN {printf \"%.1f\", (($original_size - $new_size) / $original_size) * 100}")
            local savings_int=$(awk "BEGIN {printf \"%.0f\", $potential_savings}")
            
            # Only optimize if savings are significant
            if [ $savings_int -ge $OPTIMIZATION_THRESHOLD ] || [ "$file" != "$output_file" ]; then
                [ "$file" != "$output_file" ] && rm -f "$file" && was_converted=true
                mv "$temp_file" "$output_file"
                
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + new_size))
                
                local original_fmt=$(format_size $original_size)
                local new_fmt=$(format_size $new_size)
                
                printf "  ${GREEN}✓${NC} %-30s ${DIM}%9s → %-9s${NC} ${GREEN}(%4.1f%%)${NC}" "$filename" "$original_fmt" "$new_fmt" "$potential_savings"
                
                if [ "$was_converted" = true ]; then
                    printf " ${YELLOW}[JPG]${NC}"
                    CONVERTED_FILES=$((CONVERTED_FILES + 1))
                fi
                if [ "$was_resized" = true ]; then
                    printf " ${BLUE}[${new_dimensions}]${NC}"
                    RESIZED_FILES=$((RESIZED_FILES + 1))
                fi
                echo ""
                OPTIMIZED_FILES=$((OPTIMIZED_FILES + 1))
            else
                rm -f "$temp_file"
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
                printf "  ${DIM}− %-30s${NC} ${DIM}Already optimal${NC}\n" "$filename"
                SKIPPED_FILES=$((SKIPPED_FILES + 1))
            fi
        else
            rm -f "$temp_file"
            printf "  ${RED}✗ %-30s Failed${NC}\n" "$filename"
            FAILED_FILES=$((FAILED_FILES + 1))
            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
        fi
    fi
}

# Process directory
process_directory() {
    local dir=$1
    
    if [ ! -d "$dir" ]; then
        return
    fi
    
    echo -e "${CYAN}▶${NC} Processing ${BOLD}${dir}${NC}"
    echo ""
    
    local found_files=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            ((TOTAL_FILES++))
            ((found_files++))
            optimize_image "$file"
        fi
    done < <(find "$dir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \))
    
    if [ $found_files -eq 0 ]; then
        echo -e "  ${DIM}No images found${NC}"
    fi
    
    echo ""
}

# Process both directories
process_directory "$PROJECTS_DIR"
process_directory "$HACKATHONS_DIR"

# Calculate totals
TOTAL_ORIGINAL_FMT=$(format_size $TOTAL_ORIGINAL_SIZE)
TOTAL_NEW_FMT=$(format_size $TOTAL_NEW_SIZE)

if [ $TOTAL_ORIGINAL_SIZE -gt 0 ]; then
    TOTAL_SAVINGS=$(awk "BEGIN {printf \"%.1f\", (($TOTAL_ORIGINAL_SIZE - $TOTAL_NEW_SIZE) / $TOTAL_ORIGINAL_SIZE) * 100}")
    SAVED_SIZE=$((TOTAL_ORIGINAL_SIZE - TOTAL_NEW_SIZE))
    SAVED_FMT=$(format_size $SAVED_SIZE)
else
    TOTAL_SAVINGS="0.0"
    SAVED_FMT="0 KB"
fi

# Print summary
echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}                          Summary${NC}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Files${NC}"
echo -e "    Total:           ${TOTAL_FILES}"
echo -e "    ${GREEN}Optimized:       ${OPTIMIZED_FILES}${NC}"
echo -e "    ${YELLOW}Converted:       ${CONVERTED_FILES}${NC}"
echo -e "    ${BLUE}Resized:         ${RESIZED_FILES}${NC}"
echo -e "    ${DIM}Skipped:         ${SKIPPED_FILES}${NC}"
[ $FAILED_FILES -gt 0 ] && echo -e "    ${RED}Failed:          ${FAILED_FILES}${NC}"
echo ""
echo -e "  ${BOLD}Storage${NC}"
echo -e "    Original:        ${TOTAL_ORIGINAL_FMT}"
echo -e "    Optimized:       ${TOTAL_NEW_FMT}"
echo -e "    ${GREEN}Saved:           ${SAVED_FMT} (${TOTAL_SAVINGS}%)${NC}"
echo ""
echo -e "  ${BOLD}Settings${NC}"
echo -e "    Icons:           PNG, max ${MAX_ICON_SIZE}px, compression ${PNG_COMPRESSION}"
echo -e "    Screenshots:     JPG, max ${MAX_WIDTH}px width, quality ${JPG_QUALITY}%"
echo -e "    Threshold:       Skip if savings < ${OPTIMIZATION_THRESHOLD}%"
echo ""
echo -e "${GREEN}✓ Optimization complete!${NC}"
echo ""
