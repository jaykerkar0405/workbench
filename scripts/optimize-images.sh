#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────────────────
#  optimize-images  —  Portfolio asset optimizer
#  Icons  → PNG  (lossless, max 512px)
#  Images → JPG  (85q, max 1920px, color-safe)
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# Resolve repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Nerd Font glyphs ──────────────────────────────────────────────────────────
NF_OK=""     # nf-fa-check
NF_SKIP=""   # nf-fa-minus
NF_FAIL=""   # nf-fa-times
NF_FOLDER="" # nf-md-folder
NF_IMAGE=""  # nf-fa-file_image_o
NF_WARN=""   # nf-fa-warning
NF_GEAR=""   # nf-fa-cog
NF_CHART=""  # nf-fa-bar_chart
NF_ARROW=""  # nf-fa-long_arrow_right

# ── Colours ───────────────────────────────────────────────────────────────────
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
RED=$'\033[38;5;203m'
GREEN=$'\033[38;5;114m'
YELLOW=$'\033[38;5;221m'
BLUE=$'\033[38;5;111m'
CYAN=$'\033[38;5;80m'
GREY=$'\033[38;5;245m'

# ── Defaults ──────────────────────────────────────────────────────────────────
PROJECTS_DIR="${REPO_ROOT}/src/lib/assets/projects"
HACKATHONS_DIR="${REPO_ROOT}/src/lib/assets/hackathons"
PNG_COMPRESSION=9       # zlib level, 0-9
JPG_QUALITY=85          # standard pass
JPG_FALLBACK_QUALITY=78 # used only if standard pass produces a larger file
MAX_WIDTH=1920
MAX_ICON_SIZE=512
DRY_RUN=false
FORCE=false
VERBOSE=false
SINGLE_DIR=""

# ── Counters ──────────────────────────────────────────────────────────────────
TOTAL=0 OPTIMIZED=0 CONVERTED=0 RESIZED=0 SKIPPED=0 FAILED=0
BYTES_IN=0 BYTES_OUT=0

# ─────────────────────────────────────────────────────────────────────────────
#  Helpers
# ─────────────────────────────────────────────────────────────────────────────

usage() {
	cat <<EOF
${BOLD}optimize-images${RESET} — Portfolio asset optimizer

${BOLD}USAGE${RESET}
    ./optimize-images.sh [OPTIONS]

${BOLD}OPTIONS${RESET}
    -p, --projects-dir <path>    Projects asset dir     (default: ${PROJECTS_DIR})
    -h, --hackathons-dir <path>  Hackathons asset dir   (default: ${HACKATHONS_DIR})
    -d, --dir <path>             Process a single directory only
    -q, --quality <1-100>        JPG quality            (default: ${JPG_QUALITY})
    -f, --force                  Re-process already-optimal files
        --dry-run                Preview changes without writing
    -v, --verbose                Show skipped files in detail
        --help                   Show this help

${BOLD}FILE RULES${RESET}
    icon.png / icon.jpg    →  PNG, lossless, max ${MAX_ICON_SIZE}px
    screenshot-*, image-*  →  JPG, ${JPG_QUALITY}q, max ${MAX_WIDTH}px

${BOLD}COLOUR NOTE${RESET}
    No colorspace conversion is applied. Files are processed in their native
    colour profile to avoid brightness/contrast artefacts.

EOF
	exit 0
}

die() {
	echo -e "${RED}${NF_FAIL} Error:${RESET} $*" >&2
	exit 1
}

bytes_to_human() {
	local b=$1
	if ((b >= 1048576)); then
		awk "BEGIN{printf \"%.2f MB\", $b/1048576}"
	elif ((b >= 1024)); then
		awk "BEGIN{printf \"%.1f KB\", $b/1024}"
	else
		echo "${b} B"
	fi
}

file_bytes() { stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null || echo 0; }

img_dim() { magick identify -format "%wx%h" "$1" 2>/dev/null || echo "0x0"; }

is_icon() { [[ "$(basename "$1")" =~ ^icon\.(png|jpg|jpeg)$ ]]; }
is_image() {
	local n
	n=$(basename "$1")
	[[ "$n" =~ ^(screenshot|image)- ]]
}

pct() { # pct <old> <new>
	local old=${1:-0}
	local new=${2:-0}
	if (( old == 0 )); then
		printf "0.0"
		return
	fi
	awk "BEGIN{printf \"%.1f\", (($old - $new) / $old) * 100}"
}

already_stamped() { # returns true if we've already tagged this file
	magick identify -verbose "$1" 2>/dev/null | grep -q "portfolio-optimized"
}

stamp_file() { # embed a harmless comment so we can detect re-runs
	[[ "$DRY_RUN" == true ]] && return
	magick "$1" -set comment "portfolio-optimized" "$1" 2>/dev/null || true
}

# ─────────────────────────────────────────────────────────────────────────────
#  Core: optimise a single file
# ─────────────────────────────────────────────────────────────────────────────

optimise_icon() {
	local src="$1"
	local dir
	dir=$(dirname "$src")
	local base
	base=$(basename "$src")
	base="${base%.*}"
	local dst="${dir}/${base}.png"
	local orig_bytes
	orig_bytes=$(file_bytes "$src")
	local tmp="${dir}/.${base}__opt$$.tmp.png"

	# Skip already-optimised (unless --force)
	if [[ "$FORCE" == false ]] && [[ "$dst" == "$src" ]] && already_stamped "$src"; then
		((SKIPPED++)) || true
		BYTES_OUT=$((BYTES_OUT + orig_bytes))
		[[ "$VERBOSE" == true ]] &&
			printf "  ${GREY}${NF_SKIP}${RESET} ${GREY}%-34s already optimised${RESET}\n" "$(basename "$src")"
		return
	fi

	local dim
	dim=$(img_dim "$src")
	local w
	w=$(cut -dx -f1 <<<"$dim")
	local h
	h=$(cut -dx -f2 <<<"$dim")
	local was_resized=false

	# ── Build ImageMagick command ────────────────────────────────────────────
	# KEY: we do NOT touch -colorspace.  We let the file stay in whatever
	# colour space it already is.  -strip removes EXIF/IPTC but we preserve
	# the embedded ICC profile by using -strip selectively.
	local resize_flag=""
	if ((w > MAX_ICON_SIZE || h > MAX_ICON_SIZE)); then
		resize_flag="-resize ${MAX_ICON_SIZE}x${MAX_ICON_SIZE}>"
		was_resized=true
	fi

	if [[ "$DRY_RUN" == false ]]; then
		# shellcheck disable=SC2086
		magick "$src" \
			-auto-orient \
			$resize_flag \
			-strip \
			-define png:compression-level=${PNG_COMPRESSION} \
			-define png:compression-filter=5 \
			-define png:compression-strategy=1 \
			"$tmp" 2>/dev/null ||
			{
				rm -f "$tmp"
				_record_fail "$src"
				return
			}
	fi

	local new_bytes
	new_bytes=$(file_bytes "${DRY_RUN:+$src}${DRY_RUN:-$tmp}")
	[[ "$DRY_RUN" == true ]] && new_bytes=$orig_bytes # can't know until written

	local savings
	savings=$(pct "$orig_bytes" "$new_bytes")
	local converted=false

	if [[ "$DRY_RUN" == false ]]; then
		if [[ "$src" != "$dst" ]]; then
			rm -f "$src"
			converted=true
		fi
		mv "$tmp" "$dst"
		stamp_file "$dst"
	fi

	BYTES_OUT=$((BYTES_OUT + new_bytes))
	((OPTIMIZED++)) || true
	[[ "$converted" == true ]] && ((CONVERTED++)) || true
	[[ "$was_resized" == true ]] && ((RESIZED++)) || true

	# ── Print row ─────────────────────────────────────────────────────────────
	local colour="${GREEN}"
	((new_bytes >= orig_bytes)) && colour="${YELLOW}"
	local tags=""
	[[ "$converted" == true ]] && tags+=" ${CYAN}[→PNG]${RESET}"
	[[ "$was_resized" == true ]] && tags+=" ${BLUE}[${MAX_ICON_SIZE}px]${RESET}"
	[[ "$DRY_RUN" == true ]] && tags+=" ${GREY}[dry]${RESET}"

	printf "  ${colour}${NF_OK}${RESET} %-34s ${GREY}%8s ${NF_ARROW} %-8s${RESET} ${colour}%6s%%${RESET}%s\n" \
		"$(basename "$src")" \
		"$(bytes_to_human "$orig_bytes")" \
		"$(bytes_to_human "$new_bytes")" \
		"$savings" \
		"$tags"
}

optimise_image() {
	local src="$1"
	local dir
	dir=$(dirname "$src")
	local base
	base=$(basename "$src")
	base="${base%.*}"
	local dst="${dir}/${base}.jpg"
	local orig_bytes
	orig_bytes=$(file_bytes "$src")
	local tmp="${dir}/.${base}__opt$$.tmp.jpg"

	if [[ "$FORCE" == false ]] && [[ "$dst" == "$src" ]] && already_stamped "$src"; then
		((SKIPPED++)) || true
		BYTES_OUT=$((BYTES_OUT + orig_bytes))
		[[ "$VERBOSE" == true ]] &&
			printf "  ${GREY}${NF_SKIP}${RESET} ${GREY}%-34s already optimised${RESET}\n" "$(basename "$src")"
		return
	fi

	local dim
	dim=$(img_dim "$src")
	local w
	w=$(cut -dx -f1 <<<"$dim")
	local was_resized=false

	local resize_flag=""
	if ((w > MAX_WIDTH)); then
		resize_flag="-resize ${MAX_WIDTH}x>"
		was_resized=true
	fi

	# ── Compression strategy ─────────────────────────────────────────────────
	# 1. NO -colorspace manipulation  →  avoids gamma/brightness shifts
	# 2. -alpha remove -alpha off     →  flatten transparency to white cleanly
	# 3. -auto-orient                 →  respect EXIF rotation
	# 4. -strip                       →  remove EXIF/IPTC (keeps ICC profile
	#                                    only if you use -strip selectively;
	#                                    for web we fully strip — browsers use
	#                                    sRGB by default anyway)
	# 5. -sampling-factor 4:2:0       →  standard chroma subsampling for web
	# 6. -interlace Plane             →  progressive JPEG (loads faster)
	# 7. JPEG:"$tmp"                  →  explicit format tag prevents IM from
	#                                    guessing based on extension mismatch

	if [[ "$DRY_RUN" == false ]]; then
		# shellcheck disable=SC2086
		magick "$src" \
			-auto-orient \
			$resize_flag \
			-background white \
			-alpha remove \
			-alpha off \
			-strip \
			-quality ${JPG_QUALITY} \
			-sampling-factor 4:2:0 \
			-interlace Plane \
			JPEG:"$tmp" 2>/dev/null ||
			{
				rm -f "$tmp"
				_record_fail "$src"
				return
			}

		local new_bytes
		new_bytes=$(file_bytes "$tmp")

		# ── Fallback: if JPG is bigger than original, try lower quality ──────
		if ((new_bytes > orig_bytes)); then
			# shellcheck disable=SC2086
			magick "$src" \
				-auto-orient \
				$resize_flag \
				-background white \
				-alpha remove \
				-alpha off \
				-strip \
				-quality ${JPG_FALLBACK_QUALITY} \
				-sampling-factor 4:2:0 \
				-interlace Plane \
				JPEG:"$tmp" 2>/dev/null ||
				{
					rm -f "$tmp"
					_record_fail "$src"
					return
				}
			new_bytes=$(file_bytes "$tmp")
		fi
	else
		new_bytes=$orig_bytes
	fi

	local savings
	savings=$(pct "$orig_bytes" "$new_bytes")
	local converted=false

	if [[ "$DRY_RUN" == false ]]; then
		if [[ "$src" != "$dst" ]]; then
			rm -f "$src"
			converted=true
		fi
		mv "$tmp" "$dst"
		stamp_file "$dst"
	fi

	BYTES_OUT=$((BYTES_OUT + new_bytes))
	((OPTIMIZED++)) || true
	[[ "$converted" == true ]] && ((CONVERTED++)) || true
	[[ "$was_resized" == true ]] && ((RESIZED++)) || true

	local colour="${GREEN}"
	((new_bytes >= orig_bytes)) && colour="${YELLOW}"
	local tags=""
	[[ "$converted" == true ]] && tags+=" ${CYAN}[→JPG]${RESET}"
	[[ "$was_resized" == true ]] && tags+=" ${BLUE}[${MAX_WIDTH}px]${RESET}"
	[[ "$DRY_RUN" == true ]] && tags+=" ${GREY}[dry]${RESET}"

	printf "  ${colour}${NF_OK}${RESET} %-34s ${GREY}%8s ${NF_ARROW} %-8s${RESET} ${colour}%6s%%${RESET}%s\n" \
		"$(basename "$src")" \
		"$(bytes_to_human "$orig_bytes")" \
		"$(bytes_to_human "$new_bytes")" \
		"$savings" \
		"$tags"
}

_record_fail() {
	printf "  ${RED}${NF_FAIL}${RESET} %-34s ${RED}failed${RESET}\n" "$(basename "$1")"
	((FAILED++)) || true
	BYTES_OUT=$((BYTES_OUT + $(file_bytes "$1")))
}

# ─────────────────────────────────────────────────────────────────────────────
#  Directory walker
# ─────────────────────────────────────────────────────────────────────────────

process_dir() {
	local root="$1"
	[[ -d "$root" ]] || {
		echo -e "  ${YELLOW}${NF_WARN}${RESET} ${YELLOW}Directory not found: ${root}${RESET}"
		return
	}

	echo -e "${BOLD}${NF_FOLDER} ${root}${RESET}"

	local current_sub=""
	local found=0

	while IFS= read -r -d '' file; do
		local sub
		sub=$(basename "$(dirname "$file")")

		if [[ "$sub" != "$current_sub" ]]; then
			[[ -n "$current_sub" ]] && echo ""
			echo -e "  ${DIM}${sub}/${RESET}"
			current_sub="$sub"
		fi

		((TOTAL++)) || true
		((found++)) || true
		local orig_bytes
		orig_bytes=$(file_bytes "$file")
		BYTES_IN=$((BYTES_IN + orig_bytes))

		if is_icon "$file"; then
			optimise_icon "$file"
		elif is_image "$file"; then
			optimise_image "$file"
		else
			# Not a recognised naming pattern — skip silently (or verbose)
			((SKIPPED++)) || true
			BYTES_OUT=$((BYTES_OUT + orig_bytes))
			[[ "$VERBOSE" == true ]] &&
				printf "  ${GREY}${NF_SKIP}${RESET} ${GREY}%-34s unrecognised name pattern${RESET}\n" "$(basename "$file")"
		fi

	done < <(find "$root" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | sort -z)

	if ((found == 0)); then
		echo -e "  ${GREY}no images found${RESET}"
	fi
	echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  Argument parsing
# ─────────────────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
	case "$1" in
	-p | --projects-dir)
		PROJECTS_DIR="$2"
		shift 2
		;;
	-h | --hackathons-dir)
		HACKATHONS_DIR="$2"
		shift 2
		;;
	-d | --dir)
		SINGLE_DIR="$2"
		shift 2
		;;
	-q | --quality)
		JPG_QUALITY="$2"
		shift 2
		;;
	-f | --force)
		FORCE=true
		shift
		;;
	--dry-run)
		DRY_RUN=true
		shift
		;;
	-v | --verbose)
		VERBOSE=true
		shift
		;;
	--help) usage ;;
	*) die "Unknown option: $1  (try --help)" ;;
	esac
done

# ─────────────────────────────────────────────────────────────────────────────
#  Pre-flight checks
# ─────────────────────────────────────────────────────────────────────────────

command -v magick &>/dev/null || die "ImageMagick not found.  Install: sudo apt install imagemagick"

IM_VERSION=$(magick -version | grep -oP '\d+\.\d+\.\d+' | head -n1)

# ─────────────────────────────────────────────────────────────────────────────
#  Header
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}${CYAN}optimize-images${RESET}${BOLD}  portfolio asset optimizer${RESET}"
echo -e "${GREY}────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${GREY}${NF_GEAR} ImageMagick ${IM_VERSION}${RESET}"
echo -e "  ${GREY}${NF_GEAR} JPG quality    ${JPG_QUALITY}q  (fallback ${JPG_FALLBACK_QUALITY}q)${RESET}"
echo -e "  ${GREY}${NF_GEAR} PNG compression ${PNG_COMPRESSION}/9${RESET}"
echo -e "  ${GREY}${NF_GEAR} Max icon        ${MAX_ICON_SIZE}px${RESET}"
echo -e "  ${GREY}${NF_GEAR} Max image       ${MAX_WIDTH}px${RESET}"
[[ "$DRY_RUN" == true ]] && echo -e "  ${YELLOW}${NF_WARN} DRY RUN — no files will be written${RESET}"
[[ "$FORCE" == true ]] && echo -e "  ${YELLOW}${NF_WARN} FORCE — re-processing already-optimised files${RESET}"
echo -e "${GREY}────────────────────────────────────────────────────────────${RESET}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
#  Run
# ─────────────────────────────────────────────────────────────────────────────

if [[ -n "$SINGLE_DIR" ]]; then
	process_dir "$SINGLE_DIR"
else
	process_dir "$PROJECTS_DIR"
	process_dir "$HACKATHONS_DIR"
fi

# ─────────────────────────────────────────────────────────────────────────────
#  Summary
# ─────────────────────────────────────────────────────────────────────────────

SAVED=$((BYTES_IN - BYTES_OUT))
SAVED_PCT=$(pct "$BYTES_IN" "$BYTES_OUT")

echo -e "${GREY}────────────────────────────────────────────────────────────${RESET}"
echo -e "${BOLD}${NF_CHART} Summary${RESET}"
echo ""
printf "  ${GREY}%-20s${RESET}  %s\n" "Total files" "$TOTAL"
printf "  ${GREEN}%-20s${RESET}  %s\n" "Optimised" "$OPTIMIZED"
printf "  ${CYAN}%-20s${RESET}  %s\n" "Format-converted" "$CONVERTED"
printf "  ${BLUE}%-20s${RESET}  %s\n" "Resized" "$RESIZED"
printf "  ${GREY}%-20s${RESET}  %s\n" "Skipped" "$SKIPPED"
((FAILED > 0)) && printf "  ${RED}%-20s${RESET}  %s\n" "Failed" "$FAILED"
echo ""
printf "  ${GREY}%-20s${RESET}  %s\n" "Before" "$(bytes_to_human "$BYTES_IN")"
printf "  ${GREY}%-20s${RESET}  %s\n" "After" "$(bytes_to_human "$BYTES_OUT")"
if ((SAVED > 0)); then
	printf "  ${GREEN}%-20s${RESET}  %s (%s%%)\n" "Saved" "$(bytes_to_human "$SAVED")" "$SAVED_PCT"
else
	printf "  ${YELLOW}%-20s${RESET}  %s (%s%%)\n" "Delta" "$(bytes_to_human $((-SAVED)))" "$SAVED_PCT"
fi
echo ""
echo -e "${GREY}────────────────────────────────────────────────────────────${RESET}"

if [[ "$DRY_RUN" == true ]]; then
	echo -e "  ${YELLOW}${NF_WARN} Dry run complete — no files were modified${RESET}"
elif ((FAILED == 0)); then
	echo -e "  ${GREEN}${NF_OK} Done${RESET}"
else
	echo -e "  ${YELLOW}${NF_WARN} Done with ${FAILED} failure(s)${RESET}"
fi
echo ""
