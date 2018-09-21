Tutorial and Linux script to install [Alpine Linux](https://alpinelinux.org/) server to host:  

* [xhafan's blog](https://github.com/xhafan/blog) running on [Jekyll](https://github.com/jekyll/jekyll), served by [nginx](https://nginx.org/en/) - both Jekyll and nginx running inside [Docker](https://www.docker.com) container
* .NET Core/ASP.NET Core apps - apps running inside Docker container

Why Alpine Linux as a hosting OS:
    
* small footprint on disk (~1GB for the above) so it's ideal OS into a VM at a [cheap hosting provider](https://news.ycombinator.com/item?id=16407294)
* great for hosting Docker