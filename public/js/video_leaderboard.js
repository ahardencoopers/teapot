$(document).ready(() => {
	$.ajax({
		url: '/request',
		type: 'POST',
		contentType: 'application/x-www-form-urlencoded',
		dataType: 'json',
		data: {
			action: 'get_video_leaderboard'
		},
		success: (res) => {
			$('#user-wrapper').html(res.html);
		},
		error: () => {
			alert('Something went wrong, try again later...');
		}
	});

	$('#user-wrapper').on('click', '.follow-btn', (clicked) => {
		$.ajax({
			url: '/request',
			type: 'POST',
			contentType: 'application/x-www-form-urlencoded',
			dataType: 'json',
			data: {
				action: 'follow_user',
				username: $(clicked.currentTarget).data('user')
			},
			success: (res) => {
				$(clicked.currentTarget).replaceWith(res.html);
			},
			error: () => {
				alert('Something went wrong, try again later...');
			}
		});
	});

	$('#user-wrapper').on('click', '.unfollow-btn', (clicked) => {
		$.ajax({
			url: '/request',
			type: 'POST',
			contentType: 'application/x-www-form-urlencoded',
			dataType: 'json',
			data: {
				action: 'unfollow_user',
				username: $(clicked.currentTarget).data('user')
			},
			success: (res) => {
				$(clicked.currentTarget).replaceWith(res.html);
			},
			error: () => {
				alert('Something went wrong, try again later...');
			}
		});
	});

	$('#search-users-btn').on('click', () => {
		$.ajax({
			url: '/request',
			type: 'POST',
			contentType: 'application/x-www-form-urlencoded',
			dataType: 'json',
			data: {
				action: 'search_users',
				text: $('#search-users-bar').val()
			},
			success: (res) => {
				$('#user-wrapper').html(res.html);
			},
			error: () => {
				alert('Something went wrong, try again later...');
			}
		});
	});

});
