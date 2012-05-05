#Sample webhook consumer

You can take the contents of this folder and put them into a new git repo.  This will allows you to push the repo to heroku and have a functioning webhook.

##Debugging

```bash
heroku config:add LOG_LEVEL=DEBUG
heroku logs -t
```