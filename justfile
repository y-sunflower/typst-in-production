preview:
    uv run zensical serve

typst:
    for f in docs/examples/*.typ; do typst compile "$f" --format png; done
