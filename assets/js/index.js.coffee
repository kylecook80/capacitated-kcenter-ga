(->
  $('#get-filename').on 'change', ->
    name = $('#get-filename').val().split('.')[0]
    $.post '/file/'+name, (data) ->
      if data.error
        console.log error
      else
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

    $.post '/gen/'+name,
      {
        centers: centers,
        nodes: $('#gen-nodes').val(),
        radius: $('#gen-radius').val()
      },
      (data) ->
        $('#container').empty()
        node_list = for array in data.data
          array.map (item) -> parseInt(item)
        modulus = data.num_nodes / data.centers
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
    file = $('#get-filename').val()
    generations = $('#get-generations').val()
    population_size = $('#get-population-size').val()
    crossover_rate = $('#get-crossover-rate').val()
    mutation_rate = $('#get-mutation-rate').val()
    capacity = $('#get-capacity').val()

    json_data = {
      file: file
      generations: generations
      population_size: population_size
      crossover_rate: crossover_rate
      mutation_rate: mutation_rate
      capacity: capacity
    }

    $.post '/evolve/'+file, json_data, (data) ->
      console.log data
)()
