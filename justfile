preview:
    uv run zensical serve

typst:
    for f in src/examples/*.typ; do typst compile "$f" --format png; done
