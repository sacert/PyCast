# PyCast

##### Beta Version

Searches and downloads podcasts to the user's liking. Still adding features to improve the quality of searching and downloading.


![alt tag](https://raw.githubusercontent.com/sacert/PyCast/master/PyCast/PyCastDemo.gif)

##### Installation

No installation yet, will be implemented soon.

##### How to use:

```                      
$ python PyCast.py
```

The user will be asked which podcast they would like to search for as well as a being prompted for confirmation to ensure the podcast that has been searched is the correct one.

##### Files to download options:

* `"all/All"`          -  grab every podcast available from the content provider using "All"
* `"[int]"`            -  grab specific podcast, ex: 25
* `"[int] to/- [int]"` -  grab range of podcasts, ex: 25-30
* `"new/New/latest"`   -  grab latest podcast from the content provider

##### How it works:
Filtlers through the iTunes search to look for only podcasts and returns a list of content providers. Parse out the corresponding provider's rss feed for their podcast and parse through the .mp3 files provided.

##### Requirements:
Have only tested with OS X on python 2.7 but uses only native libraries.
