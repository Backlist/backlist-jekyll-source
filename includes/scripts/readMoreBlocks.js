(function(exports) {
  var permalink;
  var categories;

  function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;

    // While there remain elements to shuffle...
    while (0 !== currentIndex) {

      // Pick a remaining element...
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex -= 1;

      // And swap it with the current element.
      temporaryValue = array[currentIndex];
      array[currentIndex] = array[randomIndex];
      array[randomIndex] = temporaryValue;
    }

    return array;
  }

  function shrinkList(list) {
    list = shuffle(list);

    if (list.length > 3)
      return list.slice(0, 3);

    return list;
  }

  function buildCategoryCollection(data) {
    if (data['contents'].length > 1) {
      var lists = new Array();

      data['contents'].forEach(function(list) {
        if (list["list_permalink"] !== permalink)
          lists.push(list);
      });
      lists = shrinkList(lists);
      data['contents'] = lists;

      return data;
    }

    return false;
  }

  function buildReadMoreBlock(collection) {
    var block = $('<div/>');
    var header = $('<h3/>').text(collection['display_name']);
    var list = $('<ul/>');

    collection['contents'].forEach(function(element) {
      var link = $('<a/>').attr('href', element['list_permalink'])
                          .text(element['list_title']);
      var byline = $('<span/>').addClass('byline')
                               .text("By " + element['author']);

      $(list).append($('<li/>').append(link).append(byline));
    })

    return $(block).append(header).append(list);
  }

  function buildInterface(collections, container) {
    collections = shrinkList(collections);

    collections.forEach(function(collection) {
      var block = buildReadMoreBlock(collection);
      $(container).find('.container').append(block);
    });
  }

  exports.initialize = function(seedCategories, seedPermalink, container) {
    categories = seedCategories;
    permalink = seedPermalink;

    var remainingCategories = categories.length;
    var categoryCollections = [];

    categories.forEach(function(category) {
      var url = '/data-includes/categories/' + category + '.json';

      $.getJSON(url, function(data) {
        if (collection = buildCategoryCollection(data))
          categoryCollections.push(collection);

        remainingCategories -= 1;
        if (remainingCategories <= 0)
          buildInterface(categoryCollections, container);
          $(container).show();
      });
    });
  }
})(this.readMoreBlocks = {});