.PHONY: docs deploy-docs

# compile the docs using jazzy
docs:
	# prereq: gem install jazzy
	jazzy \
		--clean \
		-x -target,HIPEventedProperty \
		--min-acl=public \
		--author Hipmunk \
		--author_url https://hipmunk.com \
		--github_url https://github.com/Hipmunk/HIPEventedProperty \
		--github-file-prefix https://github.com/Hipmunk/HIPEventedProperty/tree/master \
		--module HIPEventedProperty \
		--module-version 1.0 \
		--skip-undocumented \
		--root-url https://hipmunk.github.com/HIPEventedProperty

# Uploads docs to your origin/gh-pages branch
deploy-docs: docs
	# prereq: pip install ghp-import
	ghp-import docs \
		-n -p \
		-m "Update docs" \
		-r origin \
		-b gh-pages
