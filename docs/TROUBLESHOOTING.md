## Troubleshooting

We've done our best to make the DeepCell Kiosk robust to common use cases, however, there may be unforseen issues. In the following (as well as on our [FAQ](http://www.deepcell.org/faq)), we hope to cover some possible sources of fustration. If you run accross a new problem not listed in either location, please feel free to open an issue on the [DeepCell Kiosk repository](`https://www.github.com/vanvalenlab/kiosk`).

#### My prediction never finishes

A consumer should always either successfully consume a job or fail and provide an error. If a submitted prediction job never completes and the "in progress" animation is running, it is likely that the consumer pod is out of memory/CPU resources. In this case, Kubernetes responds by killing the consumer before it can complete the job. To confirm that the consumer is being `Evicted`, drop to shell and use `kubectl get pods`. There are a few ways to resolve a consumer being evicted due to resource constraints:

* Submit smaller images.

* Redeploy the cluster with the more powerful nodes than the default `n1-standard-1`.

* Increase the memory/cpu resource request in the helmfile of the consumer. (Remember to follow this by issuing the following command `helm delete consumer-name --purge; helmfile -l name=consumer-name sync`)

A prediction job may also never finish if the `tf-serving` pod never comes up. If you see that the `tf-serving` pod is not in status `Running` or has been restarting, there is likely a memory/resource issue with the model server itself. If this is the case, please read below.


#### My predictions keep failing and I have a lot of models (or model versions) in my `models` folder.

- You could be experiencing a memory issue involving TensorFlow-Serving. The solution is to reduce the number of models or model versions you have in your `models` folder. Other possible solutions, listed in descending order of likelihood of fixing your issue, include choosing GPU instances which have more memory, using smaller models, or, if possible, submitting smaller images for prediction. In our experience, using `n1-highmem-2` and `n1-highmem-4` instances, we ran into issues when we had more than ~10 model versions total across all models in the `models` folder.


#### I hit an error during cluster destruction.

If the cluster destruction script did not successfully complete, it is likely that there are still resources active in your [Google Cloud Console](https://console.cloud.google.com).  Please make sure to delete your Kubernetes Engine Cluster and any Persistent Disks/Load Balancers associated with it. To read more, please consult the [Advanced Documentation](docs/ADVANCED_DOCUMENTATION.md).
