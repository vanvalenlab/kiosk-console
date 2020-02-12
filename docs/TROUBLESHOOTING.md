## Troubleshooting

We've done our best to make the DeepCell Kiosk robust to common use cases, however, there may be unforseen issues. In the following (as well as on our [FAQ](http://www.deepcell.org/faq)), we hope to cover some possible sources of fustration. If you run accross a new problem not listed in either location, please feel free to open an issue on the [DeepCell Kiosk repository](`https://www.github.com/vanvalenlab/kiosk`).

* [My prediction never finishes](#ttoc1)
* [My predictions keep failing](#ttoc2)
* [I hit an error during cluster creation/destruction](#ttoc3)
* [I killed my docker container!](#ttoc4)

<a name="ttoc1"></a>
#### My prediction never finishes

A consumer should always either successfully consume a job or fail and provide an error. If a submitted prediction job never completes and the "in progress" animation is running, it is likely that the consumer pod is out of memory/CPU resources. In this case, Kubernetes responds by killing the consumer before it can complete the job. To confirm that the consumer is being `Evicted`, drop to shell and use `kubectl get pods`. There are a few ways to resolve a consumer being evicted due to resource constraints:

* Submit smaller images.

* Redeploy the cluster with the more powerful nodes than the default `n1-standard-1`.

* Increase the memory/cpu resource request in the helmfile of the consumer. (Remember to follow this by issuing the following command `helm delete consumer-name --purge; helmfile -l name=consumer-name sync`)

* Make sure your account has adequate quota limits (at least 1 GPU and at least 12 In-use IP Addresses).

A prediction job may also never finish if the `tf-serving` pod never comes up. If you see that the `tf-serving` pod is not in status `Running` or has been restarting, there is likely a memory/resource issue with the model server itself. If this is the case, please read below.

<a name="ttoc2"></a>
#### My predictions keep failing and I have a lot of models (or model versions) in my `models` folder

- You could be experiencing a memory issue involving TensorFlow-Serving. The solution is to reduce the number of models or model versions you have in your `models` folder. Other possible solutions, listed in descending order of likelihood of fixing your issue, include choosing GPU instances which have more memory, using smaller models, or, if possible, submitting smaller images for prediction. In our experience, using `n1-highmem-2` and `n1-highmem-4` instances, we ran into issues when we had more than roughly 10 model versions total across all models in the `models` folder.

<a name="ttoc3"></a>
#### I hit an error during cluster creation/destruction

- <b>Quota Limits:</b> A commonly-encountered problem during cluster creation, especially for new users, is a "quota shortage". (Curiously, Google Cloud refers to the limits it places on your use of different resources as "quotas".) If your available quota for a given resource (say, `n1-highmem-2` compute instances) is lower than what the DeepCell Kiosk is requesting, then your cluster creation will fail with a quota-related error message. If this occurs, you have a few options.
	1. The quickest is probably to reconfigure your cluster, going through the `Advanced` settings and changing the numbers around to reduce the demand for your quota-limited resource. However, keep in mind that your cluster performance might suffer as a result of this.
	2. Worst case, your Google Cloud account is severely quota-limited and no redistribution of resource demands is going to fix that. In that case, you should contact Google Cloud directly to ask for an increase to the relevant quota. In our experience, this process takes at least a day, for unknown reasons.

- <b>Miscellaneous Creation/Destruction Errors:</b>
	* If you encounter another error that isn't covered here during cluster creation, our fallback advice is to go have lunch, relax, and reattempt cluster creation after a short break. It has worked for us in the past.
	* If you encounter an unknown error during cluster destruction, you can't retry cluster destruction and, unfortunately, you'll need to manually clean up any lingering stray resources (see below), but then everything is taken care of.
	* If these pieces of catch-all advice don't help you, feel free to submit an issue! We'll do our best to resolve your problem and add your situation to our documentation for the benefit of future users.

- <b>Note on Failed Cluster Destruction:</b> If the cluster destruction script did not successfully complete, it is likely that there are still resources active in your [Google Cloud Console](https://console.cloud.google.com).  Please make sure to delete your Kubernetes Engine Cluster and any Persistent Disks/Load Balancers associated with it. To read more, please consult the [Advanced Documentation](ADVANCED_DOCUMENTATION.md#failcd).

<a name="ttoc4"></a>
#### I killed my docker container!

Unfortunately, your cluster is unreachable. Your cluster will remain up until it is manually destroyed, as [described here](ADVANCED_DOCUMENTATION.md#failcd). Services *should* remain stable if you want to continue to use the cluster, though debugging any issues will be impossible.

If you plan to have a long-running cluster up, it is recommended to use the [jumpbox](ADVANCED_DOCUMENTATION.md#jumpbox) deployment method in order to prevent this issue.
