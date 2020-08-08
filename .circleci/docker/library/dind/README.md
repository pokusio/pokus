# How to build

* This OCI image is required to run the circleci pipeline at ccc

* Here is how to buidl and publish this image :

```bash
export DTAG="0.0.2"
export QUAY_BOT_USERNAME=pok-us-io+pokusbot
export QUAY_BOT_SECRET=BYXO45DGHDGDGDGDRGDRDRGDRGDRGDRGDRGDRDRGDRGDRGDGDRGZ96DOXR4
echo "QUAY_BOT_USERNAME=[$QUAY_BOT_USERNAME]"
echo "QUAY_BOT_SECRET=[${QUAY_BOT_SECRET}]"
git clone	git@gitlab.com:second-bureau/pegasus/pokus/pokus.git pokustee/
cd pokustee/
git checkout feature/swagger_pipeline
docker login -u="$QUAY_BOT_USERNAME" -p="$QUAY_BOT_SECRET" quay.io
docker build --no-cache -t "quay.io/pok-us-io/pokus_api_oci_build:${DTAG}" -f .circleci/docker/library/dind/Dockerfile ./.circleci/docker/primary/dind/
docker push "quay.io/pok-us-io/pokus_api_oci_build:${DTAG}"
```
