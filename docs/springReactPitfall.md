Spring boot backend, react frontend pitfall
======
* Use `/index.html` in MVC controller to handle all URL requests for a react single page web app
* `fetch` or `XMLHttpRequest` api can not handle redirect, use form with post attribute to handle redirect when login
* `successForwardUrl` in security configuration is dangerous, will cause strange `method not supported` error, DONOT use it
* Use `antMather` at the beginning of security config to secure specific urls
* For authentication works, return `User` with username/password/role in `UserDetailsService`, and `BcryptPasswordEncoder` to encoder password
 
