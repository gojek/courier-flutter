#!/bin/bash

last_tag="$(git tag --sort=-version:refname | head -2 | tail -1)"
commit_count_since_last_tag=$(git rev-list "$last_tag..HEAD" --count)
commit_count_since_last_tag=$(($commit_count_since_last_tag - 1))

changelog=$(git log --pretty="%s (%h)" -"${commit_count_since_last_tag}")

# Format changelog
changelog="<ul>$(while IFS= read -r line; do echo -n "<li>$line</li>"; done <<<"$changelog")</ul>"
echo "$changelog"
