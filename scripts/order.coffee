# Description:
#   Temas del metano del WC
#
# Commands:
#   valorio nuevo pedido - Resetea el pedido actual
#   valorio resumen - Muestra un resumen de quién ha pedido qué
#   valorio quiero <lo que quieras> - Lo que quieres pedir (un único elemento)
#   valorio cancela <lo que quieras cancelar> - Cancela una unidad del elemento que indiques

slugify = require('slugify')

normalize = (name) =>
    return slugify(name.toLowerCase().replace(/\s/g, ""))

class Order
  users: {}
  items: {}

  addItemForUser: (item, user) =>
    normalizedName = normalize(item)
    @users[user.id] = user
    storedItem = @items[normalizedName]
    if !storedItem?
        storedItem = {
            'name': item,
            'userIds': [user.id]
        }
    else
        storedItem['userIds'].push(user.id)

    @items[normalizedName] = storedItem

  removeItemForUser: (item, user) =>
    normalizedName = normalize(item)
    @users[user.id] = user
    storedItem = @items[normalizedName]
    if storedItem?
        index = storedItem["userIds"].indexOf user.id
        storedItem["userIds"].splice index, 1 if index isnt -1
        @items[normalizedName] = storedItem

  str: =>
    result = "\n"
    for normalizedName, item of @items
        userNames = []
        for user in item['userIds']
            userNames.push(@users[user].name)

        if userNames.length > 0
            result += "#{item['name']}(#{userNames.length}): #{userNames.join(', ')}\n"

    return result

module.exports = (robot) ->
  robot.respond /nuevo pedido/, (res) ->
      robot.brain.set 'order', new Order
      res.send "A vuestras órdenes :)"

  robot.respond /resumen/, (res) ->
      order = robot.brain.get('order') or new Order
      res.send order.str()

  robot.respond /quiero (.*)/i, (res) ->
    item = res.match[1]
    order = robot.brain.get('order') or new Order
    order.addItemForUser(item, res.message.user)
    robot.brain.set 'order', order
    res.send order.str()

  robot.respond /cancela (.*)/i, (res) ->
    item = res.match[1]
    order = robot.brain.get('order') or new Order
    order.removeItemForUser(item, res.message.user)
    robot.brain.set 'order', order
    res.send order.str()
