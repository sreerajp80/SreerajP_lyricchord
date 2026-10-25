#!/usr/bin/env bash
# Fails if a Hindi marker appears in Sanskrit text: app_sa.arb, any assets/*_sa.*
# file, or assets/config/app_config.json. Copied from the language pack
# (docs/guidelines/language_packs/sanskrit_malayalam.md §4.1). It is a smoke
# test, not a proof: passing it does not mean the Sanskrit is good.
#
# Run from the project root:  bash tool/check_sanskrit_hindi_markers.sh
#
# One change from the pack's script: docs/ is skipped, so files inside the
# read-only guidelines submodule are never checked as this app's text.
set -u

# PCRE (-P) with lookarounds, so standalone copulas are not confused with
# Sanskrit words that contain the same letters. Word edges: whitespace, quotes,
# brackets, punctuation, danda, tag edges and Markdown marks.
PATTERN='(?<=[\s"'\''([{<>।,*_`#|:;~-]|^)(?:था|थे|थी|हो|है|हैं|हूं|और)(?=[\s"'\''\)\]}<>।,.\?!*_`#|:;~-]|$)|करें|करना|करके|रहा|रही|रहे|गया|गयी|चाहिए|नहीं|लेकिन|क्या|आपका|आपकी|आपके|हमारा|मेरा|कृपया|सेटिंग्स|ऐप|\x{093C}|[\x{0958}-\x{095F}]'

mapfile -t FILES < <(find . -path '*/build' -prune -o -path './docs' -prune -o -type f \( \
    -name 'app_sa.arb' -o \
    -path '*/assets/*_sa.*' -o \
    -path '*/assets/config/app_config.json' \) -print)

if [ "${#FILES[@]}" -eq 0 ]; then
  echo 'No Sanskrit files found — the project declares sa but app_sa.arb is missing.'
  exit 1
fi

# Self-test: the pattern must still catch a Hindi copula in ARB/JSON, XML and
# Markdown text.
for sample in '"greeting": "है"' '<b>है</b>' 'यह **है**' 'यह `है`' 'वह *था*'; do
  if ! printf '%s\n' "$sample" | LC_ALL=C.UTF-8 grep -qP "$PATTERN"; then
    echo "Sanskrit check self-test failed on: $sample"
    exit 1
  fi
done

if LC_ALL=C.UTF-8 grep -nP "$PATTERN" "${FILES[@]}"; then
  echo 'Hindi markers found in Sanskrit text (language pack §4.1).'
  exit 1
fi
echo "Sanskrit check passed (${#FILES[@]} file(s))."
exit 0
