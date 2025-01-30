## Get recent headers.

- Go to southwest.com from private browser.
- Search.
- Copy JSON response for https://www.southwest.com/api/air-booking/v1/air-booking/page/air/booking/shopping
- Copy as cURL.
- `cat <<END | bin/rails headers_from_curl` [paste]
