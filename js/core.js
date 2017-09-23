var cdaxml='';
var hidden=new Array();
var firstsection=new Array();
var sectionorder=[];
var collapseall;


$(document).ready(function(){
	// Input CDA Document
	$('.viewbtn').off('click').click(function(){
		var id_target=$(this).attr('id_target');
		$('.cdaview:not([id="'+id_target+'"])').hide()
		$('#'+id_target).show()
	});
	
	// View button
	$('.transform').off('click').click(function(){
		$('#viewcda').html('')
		if($(this).attr('file')!=undefined){
			cdaxml=$(this).attr('file')
		}
		else{
			cdaxml=$('#cdaxml').val()
		}
		
		new Transformation().setXml(cdaxml).setXslt('cda.xsl').transform("viewcda");
	});

	// Sam testing
	$('#getFromWebapi').off('click').on('click', function(event) {
		event.preventDefault();
		$('#viewcda').html('');

		$.ajax({
			headers: {
				Accept: "text/xml",
				'X-OA-AUTH-TOKEN': "awefwafwaefawefef"
			},
			method: 'POST',
			url: 'http://localhost:49938/handlers/WebApiHandler.ashx?action=/v1/ccda/export&ApiType=5',
			contentType: 'application/json',
			data: "{'PatientID':47022499,'TemplateName':'DefaultExportTemplate.xml','StartDate':'2017-04-20T22:51:43.647Z','EndDate':'2017-09-20T22:51:43.647Z'}"
		}).done(function(cdaxml, message, xhr) {
			new Transformation().setXml(cdaxml).setXslt('cda.xsl').setCallback(startUp).transform("viewcda");
		});
	});
});

function startUp() {
	$('#inputcda').hide(function(){
		$('#viewcda').show(function(){
			init()
			$('#inputcdabtn').show()
		})
	})
}

function init(){
	sectionorder=[];
	$('li.toc[data-code]').each(function(){
		sectionorder.push($(this).attr('data-code'))
	})
	
	$('.minimise').click(function(event){
		var section=$(this).closest('.section')
		$(this).toggleClass('fa-compress fa-expand')
		var sectiondiv=$(this).parent().parent().find('div:last')
		sectiondiv.slideToggle(function(){
			adjustWidth(section)
		})

	})
	var cdabody=$('#cdabody')
	
	cdabody.find('div.section').each(function() {
		var sect=$(this)
		$(this).hover(
			function(){
				$(this).find('.controls').show()
			},
			function(){
				$(this).find('.controls').hide()
			})
		$(this).find('table').each(function(){
			var tbl=$(this)
			if(tbl.width()>sect.width())
				sect.width(tbl.width()+20)

			var c=tbl.find('tr.duplicate').length
			if(c>0){
				if(c==1)
					var s=$('<tr class="all" style="cursor:pointer"><td colspan="5"><i class="fa fa-warning"></i> ('+c+') duplicate row hidden. Click here to <span class="show">show</span>.</td></tr>')
				else
					var s=$('<tr class="all" style="cursor:pointer"><td colspan="5"><i class="fa fa-warning"></i> ('+c+') duplicate rows hidden. Click here to <span class="show">show</span>.</td></tr>')
				tbl.prepend(s).on('click','tr.all',function(){
					if($(this).find('.show').text()=='show'){
						$(this).find('.show').text('hide')
						tbl.find('tr.duplicate').show()
					}
					else{
						$(this).find('.show').text('show')
						tbl.find('tr.duplicate').hide()
					}
					$('#cdabody').packery()
				})
			}
			c=tbl.find('tr.duplicatefirst').length
			if(c>0){
				if(c==1)
					var s=$('<tr class="first" style="cursor:pointer"><td colspan="5"><i class="fa fa-question-circle"></i> ('+c+') potential duplicate row. Click here to <span class="show1">hide</span>.</td></tr>')
				else
					var s=$('<tr class="first" style="cursor:pointer"><td colspan="5"><i class="fa fa-question-circle"></i> ('+c+') potential duplicate row. Click here to <span class="show1">hide</span>.</td></tr>')
				tbl.prepend(s).on('click','tr.first',function(){
					if($(this).find('.show1').text()=='show'){
						$(this).find('.show1').text('hide')
						tbl.find('tr.duplicatefirst').show()
					}
					else{
						$(this).find('.show1').text('show')
						tbl.find('tr.duplicatefirst').hide()
					}
					$('#cdabody').packery()
				})
			}
		})
	})

	cdabody.packery({
		stamp:'.stamp',
		columnWidth: 'div.section:not(.narr_table)',
		//columnWidth: 160,
		transitionDuration: '0.2s',
		itemSelector: 'div.section',
		gutter:10
	});
	cdabody.find('div.section:not(.recordTarget)').each( function( i, gridItem ) {
		var draggie = new Draggabilly( gridItem );
		// bind drag events to Packery
		cdabody.packery( 'bindDraggabillyEvents', draggie );
	})

	cdabody.on( 'dragItemPositioned', function(){
		orderItems()
	});
	$('.toc').off('click').click(function(){
		var section=$('.section[data-code="'+$(this).attr('data-code')+'"]')
		if(section.is(':visible')){
			section.fadeOut(function(){
				$('#cdabody').packery()
				if(hidden.indexOf(section.attr('data-code'))==-1){
					hidden.push(section.attr('data-code'))
					localStorage.setItem("hidden", hidden);
				}
			})
			$(this).addClass('hide')
			$(this).find('i.tocli').removeClass('fa-check-square-o').addClass('fa-square-o')
		}
		else{
			section.addClass('fadehighlight').fadeIn(function(){
				$('#cdabody').packery();
				$(this).removeClass('fadehighlight')
				hidden.splice(hidden.indexOf(section.attr('data-code')),1)
				localStorage.setItem("hidden", hidden);
			})
			$(this).removeClass('hide')
			$(this).find('i.tocli').removeClass('fa-square-o').addClass('fa-check-square-o')
		}
		th=$('#tochead')
		if($('li.hide.toc[data-code]').length!=0){
			if(th.find('i.fa-warning').length==0)
				th.prepend('<i class="fa fa-warning fa-lg" style="margin-right:0.5em" title="Sections are hidden"></i>')				
		}
		else{
			th.find('i.fa-warning').remove()
		}
	})
	$('#tochead').off('click').click(function(){
		$('#toc').slideToggle(function(){
			$('#cdabody').packery();
		})
	})
	$('.tocup').off('click').click(function(event){
		var li=$(this).parent()
		var section=$('.section[data-code="'+li.attr('data-code')+'"]')
		moveup(section,li,true)
		event.stopPropagation();
		event.preventDefault();
	})
	$('.tocdown').off('click').click(function(event){
		var li=$(this).parent()
		var section=$('.section[data-code="'+li.attr('data-code')+'"]')
		movedown(section,li,true)
		event.stopPropagation();
		event.preventDefault();
	})
	$('.sectionup').click(function(event){
		var section=$(this).closest('.section')
		var li=$('.toc[data-code="'+section.attr('data-code')+'"]')
		moveup(section,li,true)
	})
	$('.sectiondown').click(function(event){
		var section=$(this).closest('.section')
		var li=$('.toc[data-code="'+section.attr('data-code')+'"]')
		movedown(section,li,true)
	})

	$('.hideshow').click(function(){
		var up=$(this).find('i').hasClass('fa-compress')
		
		if(up){
			$('div.sectiontext').slideUp(function(){
				adjustWidth($(this).parent().parent())
			})
			$('.minimise').addClass('fa-expand').removeClass('fa-compress')
		}
		else{
			$('div.sectiontext').slideDown(function(){
				adjustWidth($(this).parent().parent())
			})			
			$('.minimise').addClass('fa-compress').removeClass('fa-expand')
		}
		$('#cdabody').packery();
		$('.hideshow').find('i').toggleClass('fa-compress fa-expand')
		localStorage.setItem("collapseall", up);

	})
	// Probably don't need this
	$('#restore').off('click').click(function(){
		$('#viewcda').html()
		localStorage.setItem("firstsection", []);
		new Transformation().setXml(cdaxml).setXslt('cda.xsl').transform("viewcda");
		alert('Order is restored')
		init()
	})
	$('#showall').click(function(){
		localStorage.setItem("hidden", []);
		$('.section').each(function(){
			$(this).show()
			var code=$(this).attr('data-code')
			$('.toc[data-code="'+code+'"]').removeClass('hide').find('i.tocli').addClass('fa-check-square-o').removeClass('fa-square-o')
		})
		$('#cdabody').packery()	
	})
	$('i.delete').click(function(){
		var section=$(this).closest('div.section')
		section.fadeOut(function(){
			var code=section.attr('data-code')
			if(hidden.indexOf(code)==-1){
				hidden.push(code)
				localStorage.setItem("hidden", hidden);
			}
			cdabody.packery()	
			$('.toc[data-code="'+code+'"]').addClass('hide').find('i.tocli').removeClass('fa-check-square-o').addClass('fa-square-o')
			th=$('#tochead')
			if($('li.hide.toc[data-code]').length!=0){
				if(th.find('i.fa-warning').length==0)
					th.prepend('<i class="fa fa-warning fa-lg" style="margin-right:0.5em" title="Sections are hidden"></i>')				
			}
			else{
				th.find('i.fa-warning').remove()
			}
		})		
	})


	
	if((typeof(Storage) !== "undefined")&&(localStorage!=undefined)) {
		collapseall=localStorage.collapseall

		if((collapseall==undefined)||(collapseall=='false')){
			$('div.sectiontext').show(function(){
				//adjustWidth($(this).parent().parent())
			})
			$('.hideshow').find('i').addClass('fa-compress').removeClass('fa-expand')
			$('.minimise').addClass('fa-compress').removeClass('fa-expand')
		}
		else{
			$('div.sectiontext').hide(function(){
				adjustWidth($(this).parent().parent())
			})			
			$('.hideshow').find('i').addClass('fa-expand').removeClass('fa-compress')
		}

		if(typeof(localStorage.hidden)!='undefined'){
			hidden=localStorage.hidden.split(',')
			var ihid=0;
			for (i = 0; i <hidden.length; i++){
				if((hidden[i]!==undefined)&&(hidden[i]!="")){
					var section=$('.section[data-code="'+hidden[i]+'"]')
					section.hide()
					$('.toc[data-code="'+hidden[i]+'"]').addClass('hide').find('i.tocli').removeClass('fa-check-square-o').addClass('fa-square-o')
					ihid++
				}
			}
			if(ihid>0){
				th=$('#tochead')
				th.prepend('<i class="fa fa-warning fa-lg" style="margin-right:0.5em" title="'+ihid+' sections are hidden"></i>')

			}
			if(typeof(localStorage.firstsection)!='undefined'){
			firstsection=localStorage.firstsection.split(',')
				if(firstsection.length>1){
					for (i = firstsection.length-1; i >-1; i--){
						if((firstsection[i]!==undefined)&&(firstsection[i]!="")){
							var section=$('.section[data-code="'+firstsection[i]+'"]')
							var li=$('.toc[data-code="'+section.attr('data-code')+'"]')
							moveup(section,li,false)							
							sectionorder.splice(sectionorder.indexOf(firstsection[i]),1)
						}
					}
				}
			}
		}
		
		for (i = 0; i <sectionorder.length; i++){
			firstsection.push(sectionorder[i])
		}
		$('#cdabody').packery('reloadItems');
		$('#cdabody').packery();
		var d=new Date();
		localStorage.setItem("lastaccess", d.getDate()+" "+d.getMonth()+" "+d.getFullYear());
	} else {
		$('#storagemsg').text('Your browser does not have localStorage - your preferences will not be saved')
	}


}
function adjustWidth(section){
	s=section.attr('style')
	var is=s.indexOf('width:')
	
	if(is>-1){
		var ie=s.indexOf('px;')
		sStart=s.substring(0,is)
		sEnd=s.substring(is,s.length)
		ie=sEnd.indexOf('px;');
		sEnd=sEnd.substring(ie+3,sEnd.length)
		s=sStart+sEnd;
		section.attr('style',s)
	}
	
	if(section.find('table').length>0){
		if(section.find('table').width()>section.width())
			section.width(section.find('table').width()+20)
	}
	$('#cdabody').packery();
	
}
function moveup(section,li,bRefresh){
	var curr=li
	curr.fadeOut(function(){
		var t=li.parent().find('li:first')
		t.before(curr)
		curr.fadeIn()
	})
	
	//section
	f=section.parent().find('div.section:eq(0)')
	f.before(section)
	if(bRefresh){
		var code=section.attr('data-code');
		if(firstsection.indexOf(code)==-1){
			firstsection.unshift(code)
		}
		else{
			firstsection.splice(firstsection.indexOf(code),1)
			firstsection.unshift(code)
		}
		localStorage.setItem("firstsection", firstsection);
		$('#cdabody').packery('reloadItems');
		$('#cdabody').packery();
	}

}
function movedown(section,li,bRefresh){
	curr=li
	curr.fadeOut(function(){
		t=curr.next('[data-code]')
		t.after(curr)
		curr.fadeIn()
	})

	f=section.next()
	f.after(section)
	if(bRefresh){
		var code=section.attr('data-code');
		if(firstsection.indexOf(code)==-1){
			firstsection.unshift(code)
		}
		else{
			var pos=firstsection.indexOf(code)
			if(pos<firstsection.length){
				var b=firstsection[pos+1];
				firstsection[pos+1]=firstsection[pos]
				firstsection[pos]=b
			}
			localStorage.setItem("firstsection", firstsection);
		}
		$('#cdabody').packery('reloadItems');
		$('#cdabody').packery();
	}
}
function orderItems(){
	firstsection=[];
	restore=$('#restore')
	var itemElems = $('#cdabody').packery('getItemElements');
	$( itemElems ).each( function( i, itemElem ) {
		var code=$( itemElem ).attr('data-code')
		firstsection.push(code)
		li=$('.toc[data-code="'+code+'"]')
		restore.before(li)
	});	
	localStorage.setItem("firstsection", firstsection);
}

function comparer(index) {
    return function(a, b) {
        var valA = getCellValue(a, index), valB = getCellValue(b, index)
        return $.isNumeric(valA) && $.isNumeric(valB) ? valA - valB : valA.localeCompare(valB)
    }
}
function getCellValue(row, index){ return $(row).children('td').eq(index).html() }


/**
 * Old UI Loading xml text box
 */
var xmload;
function loadtextarea(fname){
	xmload = new XMLHttpRequest();
	xmload.onreadystatechange = loaded;
	try{
		xmload.open("GET", fname,true);
	}
	catch(e){alert(e)}
	xmload.send(null);
}
var loaded = function() {
	if (xmload.readyState == 4) {
		$('#cdaxml').val(xmload.responseText)
	}
}
