##### proof of concept fastcgi mvc micro framework

this is how it looks:
```
app/
app/db
app/db/demo.db
app/conf
app/conf/config.pm
app/controllers
app/controllers/PersonController.pm
app/views
app/views/Person
app/views/Person/index.tx
app/models
app/models/Person.pm
```

example of app/conf/config.pm:
```

sub coderef {
        return "you can also add routes as coderefs\n";
}
use constant ROUTE => {
                                GET =>  { 
                                           qr#^/person/index/$# => ['Person','index'],
                                           qr#^/sub$# => \&coderef
                                        },
                                POST => {
                                           qr#^/person/add$#      => ['Person','add'],
                                        }
                      };
use constant SESSION => { key => 'chop.s', secret => 'ASD8aSD****ASdyasd6tA^%12' };
1;
```

### install

```
$ git clone https://github.com/jackdoe/chopper
$ cd chopper
$ mv example-app app
$ perl main.pl
```

nginx.conf:

```
server {
        listen       8000;
        server_name  localhost;
        location / {
                gzip off;
                fastcgi_pass  127.0.0.1:8999;
                include fastcgi_params;
        }
}
```

