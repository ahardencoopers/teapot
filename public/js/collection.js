$(document).ready(() => {
	$.ajax({
		url: '/request',
		type: 'POST',
		dataType: 'json',
		contentType: 'application/x-www-form-urlencoded',
		data: {
			action: 'get_root_page',
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
			url: 'request',
			type: 'POST',
			dataType: 'json',
			contentType: 'application/x-www-form-urlencoded',
			data: {
				action: 'search_collection',
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
					action: 'get_root_page',
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
				action: 'get_root_page',
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
