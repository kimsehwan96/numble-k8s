# Gen istio.yaml

`istioctl manifest generate -f simple.yaml > istio.yaml`

## Fix 

`perl -pi -e 's/apiVersion:\ policy\/v1beta1/apiVersion:\ policy\/v1/' istio.yaml`
`perl -pi -e 's/apiVersion:\ autoscaling\/v2beta2/apiVersion:\ autoscaling\/v2/' istio.yaml`