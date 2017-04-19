$(document).ready(() => {
	uname = [];
	stack = [];
	url = window.location.href;
	for(i=url.length-1; i>0; i--) {
		if(url[i] === '/') {
			break;
		}
		stack.push(url[i])
	}

	while(stack.length != 0) {
		uname.push(stack.pop());
	}

	uname = uname.join('');

	$.ajax({
		url: '/request',
		type: 'POST',
		dataType: 'json',
		contentType: 'application/x-www-form-urlencoded',
		data: {
			action: 'get_root_page_user',
			username: uname,
			page: 1
		},
		success: (res) => {
			$('#video-wrapper').html(res.html);
		},
		error: (errorMessage) => {
			alert('Something went wrong try again later...');
		}
	});

	$('#search-collection-btn').on('click', () => {
		$.ajax({
			url: '/request',
			type: 'POST',
			dataType: 'json',
			contentType: 'application/x-www-form-urlencoded',
			data: {
				action: 'search_collection_user',
				username: uname,
				text: $('#search-collection-bar').val()
			},
			success: (res) => {
				$('#video-wrapper').html(res.html);
			},
			error: () => {
				alert('Something went wrong, try again later...');
			}
		});
	});

	$('#video-wrapper').on('click', '#prev-link', (clicked) => {
		if($('#current-page').data('page') !== 1) {
			$.ajax({
				url: '/request',
				type: 'POST',
				dataType: 'json',
				contentType: 'application/x-www-form-urlencoded',
				data: {
					action: 'get_root_page_user',
					username: uname,
					page: $('#current-page').data('page') - 1
				},
				success: (res) => {
					$('#video-wrapper').html(res.html);
				},
				error: (errorMessage) => {
					alert('Something went wrong try again later...');
				}
			});
		}
	});

	$('#video-wrapper').on('click', '#next-link', (clicked) => {
		$.ajax({
			url: '/request',
			type: 'POST',
			dataType: 'json',
			contentType: 'application/x-www-form-urlencoded',
			data: {
				action: 'get_root_page_user',
				username: uname,
				page: $('#current-page').data('page') + 1
			},
			success: (res) => {
				$('#video-wrapper').html(res.html);
			},
			error: (errorMessage) => {
				alert('Something went wrong try again later...');
			}
		});
	});
});
