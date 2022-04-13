index.html:
	pandoc -s -c css/index.css -f markdown -t html markdown/index.md -o index.html --metadata title="Shareable Wearables"

clean:
	rm index.html

.PHONY: clean
