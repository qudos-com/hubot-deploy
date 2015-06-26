# Description:
#   Deploy apps with Hubot and GitHub Deployments.
#
# Configuration:
#   GITHUB_TOKEN
#   GITHUB_ORG
#
# Commands:
#   hubot deploy <app> - Fuck it! We'll do it live!
#   hubot deploy <app> to <environment> - Deploy <app> to the <environment>
#   hubot deploy <app>! - Force deploy <app>
#   hubot deploy <app> to <environment>! - Force deploy <app> to the <environment>
#   hubot <branch> is the default <environment> branch for <app> - Set the branch that will be deployed when the <environment> is provided
#
# Author:
#   ejholmes

module.exports = (robot) ->
  Deploy = require('../lib/deploy')(robot)
  Repo   = require('../lib/repo')(robot)

  deploy = (msg, name, options = {}) ->
    d = new Deploy(name, options).deploy (err, res, body) ->
      if (res.statusCode != 201)
        if body.message
          msg.reply body.message
        else
          msg.reply JSON.stringify(body)
      else
        msg.reply '' if process.env.NODE_ENV == 'test'

  robot.respond /deploy (\S+?)(!)?$/i, (msg) ->
    name  = msg.match[1]
    force = msg.match[2]

    deploy msg, name, force: force, user: msg.message.user.name

  robot.respond /deploy (\S+?) to (\S+?)(!)?$/i, (msg) ->
    name        = msg.match[1]
    environment = msg.match[2]
    force       = msg.match[3]
    
    deploy msg, name, environment: environment, force: force, user: msg.message.user.name

  robot.respond /(\S+?) is the default (\S+?) branch for (\S+)/i, (msg) ->
    branch      = msg.match[1]
    environment = msg.match[2]
    name        = msg.match[3]
    repo        = new Repo(name)

    repo.setBranch environment, branch

    msg.reply "Ok, the default branch for #{name} when deployed to #{environment} is #{branch}"
