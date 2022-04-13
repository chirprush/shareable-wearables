index.html:
	pandoc -s -c css/index.css -f markdown -t html markdown/index.md -o index.html

clean:
	rm index.html

.PHONY: clean
