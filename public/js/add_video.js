$(document).ready(() => {
	$('#add-video').on('click', () => {
		if($($('input')[0]).val() === '') {
			alert('Please enter all fields');
		}
		else if ($($('input')[0]).val().match(/https:\/\/www\.youtube\.com\/watch\?v=.+/) !== null) {
			$.ajax({
				url: 'request',
				type: 'POST',
				dataType: 'json',
				contentType: 'application/x-www-form-urlencoded',
				data: {
					action: 'add_video',
					url: $($('input')[0]).val()
				},
				success: (res) => {
					alert('Video added succesfully');
				},
				error: (errorMessage) => {
					alert('Something went wrong, try again later...');
				}
			});
		}
		else {
			alert('Please enter a valid Youtube URL');
		}
	});
});
