## Troubleshooting

We've done our best to make the DeepCell Kiosk robust to common use cases, however, there may be unforseen issues. In the following (as well as on our [FAQ](http://www.deepcell.org/faq)), we hope to cover some possible sources of fustration. If you run accross a new problem not listed in either location, please feel free to open an issue on the [DeepCell Kiosk repository](`https://www.github.com/vanvalenlab/kiosk`).

#### My predictions keep failing and I have a lot of models (or model versions) in my `models` folder.
- You could be experiencing a memory issue involving TensorFlow-Serving. The solution is to reduce the number of models or model versions you have in your models\` folder. Other possible solutions, listed in descending order of likelihood of fixing your issue, include choosing GPU instances which have more memory, using smaller models, or, if possible, submitting smaller images for prediction. In our experience, using n1-highmem-2 and n1-highmem-4 instances, we ran into issues when we had more than ~10 model versions total across all models in the `models` folder. Your mileage may vary based on a variety of factors.
