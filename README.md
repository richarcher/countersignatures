`bundle exec install`
`bundle exec rake`

POST to `localhoast:4567` with 2 params: 

`echosign_url` - The url of the document to be signed with Phantom
`document_guid` - The ID of the document being signed on Platform - would be useful for calling back to Platform to handle success/failures