import consumer from './consumer'

window.addEventListener('load', function (e) {
  let fromMemberId = document.getElementById('message_from_member_id').value
  let toMemberId = document.getElementById('message_to_member_id').value
  let channel = { channel: 'TimelineChannel', fromMemberId: fromMemberId, toMemberId: toMemberId }
  const appTimeline = consumer.subscriptions.create(channel, {
    connected: function (data) {
      console.log("=======================================")
      console.log(data)
      console.log('OK connection')
      // Called when the subscription is ready for use on the server
    },

    disconnected: function () {
      // Called when the subscription has been terminated by the server
      console.log('OK disconnection')
    },

    received: function (data) {
      console.log('------------------------------->')
      console.log(data)
      return alert(data['message'])
      // Called when there's incoming data on the websocket for this channel
    },
    speak: function (message) {
      return this.perform('speak', { message: message })
    }
  })

  window.addEventListener('keypress', function (e) {
    if (e.keyCode === 13) {
      let fromMemberId = document.getElementById('message_from_member_id').value
      let toMemberId = document.getElementById('message_to_member_id').value
      let tokenForApi = document.getElementById('message_token_for_api').value
      let postData = {
        from_member_id: fromMemberId,
        to_member_id: toMemberId,
        token_for_api: tokenForApi,
        message: e.target.value
      }
      console.log(postData)
      alert(e.target.value)
      appTimeline.speak(postData)
      e.target.value = ''
      e.preventDefault()
    }
  })
})
