preview:
    uv run zensical serve

typst:
    for f in src/examples/*.typ; do typst compile "$f" --format png; done
    for f in src/examples/*.png; do mv "$f" src/images; done
