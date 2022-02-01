AWESOMEDEMO_NS=kpack-awesomedemo 

mode-demo-on:
	echo "TO DO with YTT"

mode-demo-off:
	echo "TO DO with YTT"

.PHONY: kpack

kpack:
	kapp deploy -c --yes -a kpack -f https://github.com/pivotal/kpack/releases/download/v0.4.3/release-0.4.3.yaml

namespace:
	kubectl create namespace $(AWESOMEDEMO_NS) --dry-run=client -o yaml | kubectl apply -f -
	kubectl get namespace $(AWESOMEDEMO_NS) 

shared: namespace		
	ytt --ignore-unknown-comments -f kpack/shared --data-values-env AWESOMEDEMO | kapp deploy -c --yes --into-ns $(AWESOMEDEMO_NS) -a kpack-awesomedemo-shared -f-

nodejs: 
	kapp deploy -c --yes --into-ns $(AWESOMEDEMO_NS) -f kpack/nodejs  -a kpack-awesomedemo-nodejs

check_nodejs: 
	kubectl get Builder -n $(AWESOMEDEMO_NS) node-builder
	kubectl get Image -n $(AWESOMEDEMO_NS) cnb-nodejs-image
	kubectl get builds.kpack.io -n $(AWESOMEDEMO_NS)

un_nodejs:
	kapp delete --yes -a kpack-awesomedemo-nodejs

springboot: 
	kapp deploy -c --yes --into-ns $(AWESOMEDEMO_NS) -f kpack/springboot  -a kpack-awesomedemo-springboot

check_springboot: 
	kubectl get Builder -n $(AWESOMEDEMO_NS) springboot-builder-11.0.10 springboot-builder-11.0.12
	kubectl get Image -n $(AWESOMEDEMO_NS) cnb-springboot-image
	kubectl get builds.kpack.io -n $(AWESOMEDEMO_NS)

un_springboot:
	kapp delete --yes -a kpack-awesomedemo-springboot

dotnetcore: 
	kapp deploy -c --yes --into-ns $(AWESOMEDEMO_NS) -f kpack/dotnetcore  -a kpack-awesomedemo-dotnetcore

check_dotnetcore:
	kubectl get Builder -n $(AWESOMEDEMO_NS) dotnetcore-builder  
	kubectl get Image -n $(AWESOMEDEMO_NS) cnb-dotnetcore-image
	kubectl get builds.kpack.io -n $(AWESOMEDEMO_NS)

un_dotnetcore:
	kapp delete --yes -a kpack-awesomedemo-dotnetcore
