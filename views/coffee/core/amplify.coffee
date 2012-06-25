amplify.request.decoders.entityResponse = 
  (data, status, xhr, success, error) ->
    if data.success
      success(data.data)
    else
      error(data.message)

amplify.request.define 'loadById', 'ajax', 
  url: '/load/{id}'
  dataType: 'json'
  type: 'GET'
  cache: 5000
  decoder: 'entityResponse'

titan.add_helper 'loadById', (id, fn) ->
  amplify.request
    resourceId: 'loadById'
    data: {id:id}
    success: (data) -> fn(data)
    error: (message) -> alert(message)