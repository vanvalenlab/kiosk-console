```filenaming conventions```
- input files (direct and via web interface)

```microservice architecture```



TROUBLESHOOTING:
If your predictions keep failing and you have a lot of models (or model versions) in your `models` folder, you could be experiencing a memory issue involving Tensorflow-Serving. The solution is to reduce the number of models or model versions you have in your models` folder. Other possible solutions, listed in descending order of likelihood of fixing your issue, include choosing GPU instances which have more memory, using smaller models,or, if possible, submitting smaller images for prediction. In our experience, using n1-highmem-2 and n1-highmem-4 instances, we ran into issues when we had more than ~10 model versions total across all models in the `models` folder. Your mileage may vary based on a variety of factors.
