#!/bin/bash

# ============================================================================
# Image Optimization Script for Portfolio
# ============================================================================
# Optimizes images in projects and hackathons directories
# - Icons (icon.png/jpg) → PNG format with lossless compression
# - Screenshots and images → JPG format (only if smaller than PNG)
# ============================================================================

set -e

# Colors (minimal and professional)
GRAY='\033[0;90m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Configuration
PROJECTS_DIR="src/lib/assets/projects"
HACKATHONS_DIR="src/lib/assets/hackathons"
PNG_QUALITY=90
PNG_COMPRESSION=9
JPG_QUALITY=85

# Counters
TOTAL_FILES=0
OPTIMIZED_FILES=0
CONVERTED_FILES=0
SKIPPED_FILES=0
FAILED_FILES=0
TOTAL_ORIGINAL_SIZE=0
TOTAL_NEW_SIZE=0

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo -e "${RED}Error: ImageMagick is not installed${NC}"
    echo "Install: sudo apt install imagemagick"
    exit 1
fi

# Header
echo ""
echo -e "${BOLD}Image Optimization${NC}"
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to format file size
format_size() {
    local size=$1
    if [ $size -ge 1048576 ]; then
        awk "BEGIN {printf \"%.2f MB\", $size / 1048576}"
    else
        awk "BEGIN {printf \"%.2f KB\", $size / 1024}"
    fi
}

# Function to get file size in bytes
get_file_size() {
    local file="$1"
    if [ -f "$file" ]; then
        stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Function to check if file is an icon
is_icon() {
    local filename=$(basename "$1")
    [[ "$filename" == "icon.png" ]] || [[ "$filename" == "icon.jpg" ]] || [[ "$filename" == "icon.jpeg" ]]
}

# Function to optimize image
optimize_image() {
    local file="$1"
    local filename=$(basename "$file")
    local dirname=$(dirname "$file")
    local extension="${filename##*.}"
    local basename="${filename%.*}"
    
    # Get original size
    local original_size=$(get_file_size "$file")
    TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + original_size))
    
    local output_file="$file"
    local temp_file="${dirname}/.${basename}_temp"
    
    # Determine optimization strategy
    if is_icon "$file"; then
        # ============================================================
        # ICONS: Convert to PNG with lossless compression
        # ============================================================
        output_file="${dirname}/${basename}.png"
        temp_file="${output_file}.tmp"
        
        magick "$file" -strip -quality $PNG_QUALITY -define png:compression-level=$PNG_COMPRESSION "$temp_file" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            local new_size=$(get_file_size "$temp_file")
            
            if [ $new_size -le $original_size ] || [ "$file" == "$output_file" ]; then
                [ "$file" != "$output_file" ] && rm -f "$file"
                mv "$temp_file" "$output_file"
                
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + new_size))
                
                local savings=$(awk "BEGIN {printf \"%.1f\", (($original_size - $new_size) / $original_size) * 100}")
                local original_fmt=$(format_size $original_size)
                local new_fmt=$(format_size $new_size)
                
                if [ "$file" != "$output_file" ]; then
                    echo -e "  ${GREEN}✓${NC} ${BOLD}icon.${extension}${NC} → ${BOLD}icon.png${NC}  ${DIM}${original_fmt} → ${new_fmt} (${savings}% saved)${NC}"
                    CONVERTED_FILES=$((CONVERTED_FILES + 1))
                else
                    echo -e "  ${GREEN}✓${NC} ${BOLD}${filename}${NC}  ${DIM}${original_fmt} → ${new_fmt} (${savings}% saved) [PNG-${PNG_COMPRESSION}]${NC}"
                fi
                OPTIMIZED_FILES=$((OPTIMIZED_FILES + 1))
            else
                rm -f "$temp_file"
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
                echo -e "  ${GRAY}−${NC} ${DIM}${filename}  Already optimal${NC}"
                SKIPPED_FILES=$((SKIPPED_FILES + 1))
            fi
        else
            echo -e "  ${RED}✗${NC} ${filename}  ${RED}Failed${NC}"
            FAILED_FILES=$((FAILED_FILES + 1))
            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
            rm -f "$temp_file"
        fi
        
    elif [[ "$filename" == screenshot-* ]] || [[ "$filename" == image-* ]]; then
        # ============================================================
        # SCREENSHOTS/IMAGES: Try JPG conversion, fallback to PNG
        # ============================================================
        output_file="${dirname}/${basename}.jpg"
        temp_file="${output_file}.tmp"
        
        magick "$file" -strip -quality $JPG_QUALITY -sampling-factor 4:2:0 -interlace Plane "$temp_file" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            local new_size=$(get_file_size "$temp_file")
            
            if [ $new_size -lt $original_size ]; then
                # JPG is smaller - use it
                [ "$file" != "$output_file" ] && rm -f "$file"
                mv "$temp_file" "$output_file"
                
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + new_size))
                
                local savings=$(awk "BEGIN {printf \"%.1f\", (($original_size - $new_size) / $original_size) * 100}")
                local original_fmt=$(format_size $original_size)
                local new_fmt=$(format_size $new_size)
                
                if [ "$file" != "$output_file" ]; then
                    echo -e "  ${GREEN}✓${NC} ${BOLD}${filename}${NC} → ${BOLD}${basename}.jpg${NC}  ${DIM}${original_fmt} → ${new_fmt} (${savings}% saved) [JPG-${JPG_QUALITY}]${NC}"
                    CONVERTED_FILES=$((CONVERTED_FILES + 1))
                else
                    echo -e "  ${GREEN}✓${NC} ${BOLD}${filename}${NC}  ${DIM}${original_fmt} → ${new_fmt} (${savings}% saved) [JPG-${JPG_QUALITY}]${NC}"
                fi
                OPTIMIZED_FILES=$((OPTIMIZED_FILES + 1))
            else
                # PNG is smaller - optimize PNG instead
                rm -f "$temp_file"
                temp_file="${file}.tmp"
                
                if [[ "$extension" == "png" ]]; then
                    magick "$file" -strip -quality $PNG_QUALITY -define png:compression-level=$PNG_COMPRESSION "$temp_file" 2>/dev/null
                    
                    if [ $? -eq 0 ]; then
                        local new_size=$(get_file_size "$temp_file")
                        
                        if [ $new_size -lt $original_size ]; then
                            mv "$temp_file" "$file"
                            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + new_size))
                            
                            local savings=$(awk "BEGIN {printf \"%.1f\", (($original_size - $new_size) / $original_size) * 100}")
                            local original_fmt=$(format_size $original_size)
                            local new_fmt=$(format_size $new_size)
                            
                            echo -e "  ${GREEN}✓${NC} ${BOLD}${filename}${NC}  ${DIM}${original_fmt} → ${new_fmt} (${savings}% saved) [PNG-${PNG_COMPRESSION}]${NC}"
                            OPTIMIZED_FILES=$((OPTIMIZED_FILES + 1))
                        else
                            rm -f "$temp_file"
                            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
                            echo -e "  ${GRAY}−${NC} ${DIM}${filename}  Already optimal${NC}"
                            SKIPPED_FILES=$((SKIPPED_FILES + 1))
                        fi
                    else
                        TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
                        echo -e "  ${GRAY}−${NC} ${DIM}${filename}  Already optimal${NC}"
                        SKIPPED_FILES=$((SKIPPED_FILES + 1))
                    fi
                else
                    # Already JPG, optimize it
                    magick "$file" -strip -quality $JPG_QUALITY -sampling-factor 4:2:0 -interlace Plane "$temp_file" 2>/dev/null
                    
                    if [ $? -eq 0 ]; then
                        local new_size=$(get_file_size "$temp_file")
                        
                        if [ $new_size -lt $original_size ]; then
                            mv "$temp_file" "$file"
                            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + new_size))
                            
                            local savings=$(awk "BEGIN {printf \"%.1f\", (($original_size - $new_size) / $original_size) * 100}")
                            local original_fmt=$(format_size $original_size)
                            local new_fmt=$(format_size $new_size)
                            
                            echo -e "  ${GREEN}✓${NC} ${BOLD}${filename}${NC}  ${DIM}${original_fmt} → ${new_fmt} (${savings}% saved) [JPG-${JPG_QUALITY}]${NC}"
                            OPTIMIZED_FILES=$((OPTIMIZED_FILES + 1))
                        else
                            rm -f "$temp_file"
                            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
                            echo -e "  ${GRAY}−${NC} ${DIM}${filename}  Already optimal${NC}"
                            SKIPPED_FILES=$((SKIPPED_FILES + 1))
                        fi
                    else
                        TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
                        echo -e "  ${GRAY}−${NC} ${DIM}${filename}  Already optimal${NC}"
                        SKIPPED_FILES=$((SKIPPED_FILES + 1))
                    fi
                fi
            fi
        else
            echo -e "  ${RED}✗${NC} ${filename}  ${RED}Failed${NC}"
            FAILED_FILES=$((FAILED_FILES + 1))
            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
            rm -f "$temp_file"
        fi
    else
        # ============================================================
        # OTHER: Optimize in original format
        # ============================================================
        temp_file="${file}.tmp"
        
        if [[ "$extension" == "png" ]]; then
            magick "$file" -strip -quality $PNG_QUALITY -define png:compression-level=$PNG_COMPRESSION "$temp_file" 2>/dev/null
        else
            magick "$file" -strip -quality $JPG_QUALITY -sampling-factor 4:2:0 -interlace Plane "$temp_file" 2>/dev/null
        fi
        
        if [ $? -eq 0 ]; then
            local new_size=$(get_file_size "$temp_file")
            
            if [ $new_size -lt $original_size ]; then
                mv "$temp_file" "$file"
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + new_size))
                
                local savings=$(awk "BEGIN {printf \"%.1f\", (($original_size - $new_size) / $original_size) * 100}")
                local original_fmt=$(format_size $original_size)
                local new_fmt=$(format_size $new_size)
                
                echo -e "  ${GREEN}✓${NC} ${BOLD}${filename}${NC}  ${DIM}${original_fmt} → ${new_fmt} (${savings}% saved)${NC}"
                OPTIMIZED_FILES=$((OPTIMIZED_FILES + 1))
            else
                rm -f "$temp_file"
                TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
                echo -e "  ${GRAY}−${NC} ${DIM}${filename}  Already optimal${NC}"
                SKIPPED_FILES=$((SKIPPED_FILES + 1))
            fi
        else
            echo -e "  ${RED}✗${NC} ${filename}  ${RED}Failed${NC}"
            FAILED_FILES=$((FAILED_FILES + 1))
            TOTAL_NEW_SIZE=$((TOTAL_NEW_SIZE + original_size))
            rm -f "$temp_file"
        fi
    fi
}

# Process projects directory
if [ -d "$PROJECTS_DIR" ]; then
    echo -e "${DIM}Scanning${NC} ${PROJECTS_DIR}"
    echo ""
    
    while IFS= read -r -d '' file; do
        TOTAL_FILES=$((TOTAL_FILES + 1))
        optimize_image "$file"
    done < <(find "$PROJECTS_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0)
fi

# Process hackathons directory
if [ -d "$HACKATHONS_DIR" ]; then
    echo ""
    echo -e "${DIM}Scanning${NC} ${HACKATHONS_DIR}"
    echo ""
    
    while IFS= read -r -d '' file; do
        TOTAL_FILES=$((TOTAL_FILES + 1))
        optimize_image "$file"
    done < <(find "$HACKATHONS_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0)
fi

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
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}Summary${NC}"
echo ""
echo -e "  Total files:     ${TOTAL_FILES}"
echo -e "  ${GREEN}Optimized:       ${OPTIMIZED_FILES}${NC}"
echo -e "  ${YELLOW}Converted:       ${CONVERTED_FILES}${NC}"
echo -e "  ${GRAY}Skipped:         ${SKIPPED_FILES}${NC}"
[ $FAILED_FILES -gt 0 ] && echo -e "  ${RED}Failed:          ${FAILED_FILES}${NC}"
echo ""
echo -e "  Original size:   ${TOTAL_ORIGINAL_FMT}"
echo -e "  New size:        ${TOTAL_NEW_FMT}"
echo -e "  ${GREEN}Saved:           ${SAVED_FMT} (${TOTAL_SAVINGS}%)${NC}"
echo ""
echo -e "${GRAY}Compression: PNG-${PNG_COMPRESSION} (lossless), JPG-${JPG_QUALITY} (lossy)${NC}"
echo ""
