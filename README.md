# mkdocs➜  

Nutanix-use-case git:(master) ✗ docker run -v ${PWD}:/mkdocs-site  mkdocs:latest new test
INFO    -  Creating project directory: test
INFO    -  Writing config file: test/mkdocs.yml
INFO    -  Writing initial docs: test/docs/index.md


➜  Nutanix-use-case git:(master) ✗ docker run -v ${PWD}/test:/mkdocs-site -it -d --name mkdocs  mkdocs:latest build


➜  Nutanix-use-case git:(master) ✗ docker run -v ${PWD}/test:/mkdocs-site -p 8000:8000 -it -d --rm --name mkdocs  mkdocs:latest serve --dev-addr=0.0.0.0:8000
24c17db20ae759758914b89fca0c0d2f991489a8b8fc4afa96d37e5ed0cbff5e