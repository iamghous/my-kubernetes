# we will first build the images, we will add two tags to each image, one lates and the other one
# is the env variable which simply gets the curent SHA from git which looks something like "f786c2198"
docker build -t iamnoman07/multi-client:latest -t iamnoman07/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t iamnoman07/multi-server:latest -t iamnoman07/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t iamnoman07/multi-worker:latest -t iamnoman07/multi-worker:$SHA -f ./worker/Dockerfile ./worker

# we will now push these images, we dont need to login to docker to push images,
# because we have already logged in docker in .travis yaml file
docker push iamnoman07/multi-client:latest
docker push iamnoman07/multi-server:latest
docker push iamnoman07/multi-worker:latest

# will now push these images, with the latest git SHA as version
docker push iamnoman07/multi-client:$SHA
docker push iamnoman07/multi-server:$SHA
docker push iamnoman07/multi-worker:$SHA

# since we have configured kubectl in travis.yml file we can apply the k8s directory simple
kubectl apply -f k8s

# now because our deployments files are not being changed, kubectl will not pull the latest image from dockerhub
# because it will say "Oh nothing has changed inside the file so why do i pull new images??"
# now we will manually add commands to ask kubernetes to pull the latest images for our deploymet files
# to do that we have tagged images with env variable which is different everytime travis automatically runs
# and therefore it will pull those images


kubectl set image deployments/client-deployment client=iamnoman07/multi-client:$SHA
kubectl set image deployments/server-deployment server=iamnoman07/multi-server:$SHA
kubectl set image deployments/worker-deployment worker=iamnoman07/multi-worker:$SHA