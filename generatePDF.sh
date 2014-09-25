#!/bin/bash

clone_repos() {
	git clone https://github.com/cloudfoundry/docs-book-cloudfoundry
	git clone https://github.com/cloudfoundry/docs-cloudfoundry-concepts
	git clone https://github.com/cloudfoundry/docs-dev-guide
	git clone https://github.com/cloudfoundry/docs-cf-admin
	git clone https://github.com/cloudfoundry/docs-services
	git clone https://github.com/cloudfoundry/docs-deploying-cf
	git clone https://github.com/cloudfoundry/docs-bosh
	git clone https://github.com/cloudfoundry/docs-running-cf
	git clone https://github.com/cloudfoundry/docs-buildpacks
}

publish_book_local() {
	gem install --conservative bundler
	bundle check || bundle install

	# Bring up the Docs at http://localhost:4567
	bundle exec bookbinder publish local
}

generate_pdf() {
	bundle exec bookbinder generate_pdf pdf.yml
}

cf_commandline_install() {
	if [ ! -f cf ]; then
		wget http://go-cli.s3-website-us-east-1.amazonaws.com/releases/latest/cf-linux-amd64.tgz
		tar -zxvf cf-linux-amd64.tgz
	fi

	./cf --version
}

cf_upload() {
	cf_commandline_install

	./cf login -a $1 -u $2 -p $3 -o $4 -s $5

	set -e
	./cf push $6 -p stage -b https://github.com/cloudfoundry-community/nginx-buildpack
}

execute() {
	if [ $# -lt 6 ]; then
		export SKIP_UPLOAD=true
	fi

	clone_repos
	cd docs-book-cloudfoundry
	publish_book_local
	java -cp ../target/PDFConfigFileGenerator-0.0.1-SNAPSHOT.jar com.rahul.learn.Application $PWD/final_app/public
	cp ../pdf_header.html $PWD/final_app/public
	
	generate_pdf
	
	if [ $SKIP_UPLOAD != true ]; then
		cd ..
		mkdir -p stage
	
		mv docs-book-cloudfoundry/final_app/*.pdf stage
		mv index.html stage
		cf_upload $1 $2 $3 $4 $5 $6
	else
		echo "skipping upload as the parameters are missing"
	fi	
}

execute