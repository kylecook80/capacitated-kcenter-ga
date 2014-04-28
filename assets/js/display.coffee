GA = require './ga'

non_trivial = {"centers":[[50,50],[50,100],[50,150],[100,50],[100,100],[100,150],[150,50],[150,100],[150,150]],"nodes":[[50,50],[58,48],[60,60],[53,58],[54,52],[40,55],[45,52],[48,53],[52,48],[58,58],[53,42],[49,57],[43,51],[51,58],[56,54],[53,48],[58,51],[42,51],[46,57],[57,48],[50,100],[51,95],[40,103],[47,102],[53,91],[60,92],[57,93],[54,99],[53,100],[42,105],[55,94],[55,93],[43,90],[47,107],[57,99],[54,98],[48,110],[44,110],[58,102],[44,97],[50,150],[51,156],[42,150],[58,144],[53,159],[41,140],[45,148],[60,155],[48,149],[57,152],[51,158],[45,153],[45,157],[55,141],[41,154],[41,157],[56,148],[42,155],[58,148],[48,160],[100,50],[105,43],[105,49],[94,41],[107,49],[97,49],[93,57],[101,41],[100,52],[108,51],[101,45],[95,57],[98,47],[96,58],[91,53],[96,40],[106,56],[103,50],[91,59],[91,46],[100,100],[109,100],[93,92],[105,94],[90,102],[98,109],[108,102],[90,102],[99,93],[104,97],[94,100],[102,102],[93,110],[104,103],[96,109],[103,94],[105,97],[108,98],[102,96],[101,90],[100,150],[104,141],[107,160],[94,159],[93,146],[92,147],[95,148],[97,150],[96,140],[104,146],[95,149],[99,149],[103,151],[90,160],[98,156],[93,143],[98,141],[98,145],[110,146],[106,158],[150,50],[158,59],[149,45],[144,41],[146,58],[145,56],[149,40],[141,60],[149,41],[151,47],[149,49],[156,55],[150,45],[143,59],[158,42],[149,50],[160,44],[156,42],[150,45],[145,41],[150,100],[147,98],[155,109],[149,91],[153,90],[159,90],[151,93],[146,98],[140,106],[143,103],[156,105],[146,108],[147,95],[150,96],[160,94],[154,95],[160,96],[153,98],[140,97],[145,92],[150,150],[150,157],[157,150],[156,155],[159,160],[158,154],[158,159],[147,154],[155,140],[157,153],[141,140],[145,157],[158,144],[142,141],[141,147],[141,144],[149,140],[160,154],[142,149],[155,154]]}
trivial = {"centers": [[4,4],[4,10],[10,4],[10,10]],"nodes": [[4,4],[4,5],[5,4],[3,4],[4,3],[4,10],[4,11],[5,10],[3,10],[4,9],[10,4],[10,5],[11,4],[9,4],[10,3],[10,10],[10,11],[11,10],[9,10],[10,9]]}

$('#get-filename').on 'change', ->
  name = $('#get-filename').val().split('.')[0]
  $('#container').empty()
  modulus = data.num_nodes / data.centers
  generate_graph data.data, modulus, null

$('#input-center').keypress (event) ->
    if event.which == 13
      $('#add-center').click()

$('#gen-file').on 'click', ->
  name = $('#gen-filename').val()
  centers = []
  $('#centers-list').children().each (idx, el) ->
    centers.push $(el).html().split('</i> ')[1].split(',')
  $('#container').empty()
  node_list = for array in data.data
    array.map (item) -> parseInt(item)
  # modulus =  / centers.length
  generate_graph node_list, modulus, null
  $('#get-filename').append '<option value="' + name + '.json">' + name + '.json' + '</option>'
  $('#get-filename').val(name + '.json')

$('#add-center').on 'click', ->
  center = $('#input-center').val()
  if center.match(/^\d+,\d+$/)
    $('#centers-list').append '<li><i class="fa fa-times"></i> '+center+'</li>'
    $('#input-center').val('')
    $('#input-center').focus()

$(document).on 'click', '.fa-times', (e) ->
  $(e.currentTarget).parent().remove()

$('#start-evolve').on 'click', (e) ->
  data_set = $('#get-data-set').val()
  crossover_operator = $('#get-crossover-operator').val()
  mutation_operator = $('#get-mutation-operator').val()
  generations = parseInt $('#get-generations').val()
  population_size = parseInt $('#get-population-size').val()
  crossover_rate = parseFloat $('#get-crossover-rate').val()
  mutation_rate = parseFloat $('#get-mutation-rate').val()
  centers = parseInt $('#get-centers').val()
  capacity = parseInt $('#get-capacity').val()

  $("img.loading").css("display", "inline")
  data = non_trivial

  nodes = data.nodes
  center_nodes = data.centers

  k_center = new GA
    data: nodes
    population_size: population_size
    generations: generations
    mutation: mutation_rate
    crossover: crossover_rate
    centers: centers
    capacity: capacity

  results = k_center.generational_run()
  lines = results.lines
  generate_graph nodes, nodes.length/center_nodes.length, lines

  $("img.loading").css("display", "none")
