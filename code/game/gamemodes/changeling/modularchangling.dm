var/list/powers = subtypesof(/datum/power/carrion)	//needed for the badmin verb for now
var/list/datum/power/carrion/powerinstances = list()

/datum/power //Could be used by other antags too
	var/name = "Power"
	var/desc = "Placeholder"
	var/helptext = ""

/datum/power/carrion
	var/genomecost = 500000 // Cost for the carrion to evolve this power.
	var/organpath //Path to the organ that is getting evolved.
	var/spiderpath //The path of the spider we spawn.

/datum/power/carrion/flashbang_spider
	name = "Flashbang spider"
	desc = "Creates a spider filled with a strange substance that when activated explodes in a flash of light. Does minor damage to its host."
	genomecost = 5
	spiderpath = /obj/item/implant/carrion_spider/flashbang

/datum/power/carrion/control_spider
	name = "Control spider"
	desc = "Creates a mind controling spider with a neural link to you, giving you the abilty to control a weak minded host."
	genomecost = 5
	spiderpath = /obj/item/implant/carrion_spider/control

/datum/power/carrion/infection_spider
	name = "Infection spider"
	desc = "Creates a miniature spider, with spider core inside it capable of making more carrions."
	helptext = "Requires 7 evolution points to produce."
	genomecost = 0
	spiderpath = /obj/item/implant/carrion_spider/infection

/datum/power/carrion/healing_spider
	name = "Healing spider"
	desc = "Evolves a spider filled with a mixture of medicinal chemicals."
	genomecost = 4
	spiderpath = /obj/item/implant/carrion_spider/healing

/datum/power/carrion/blight_spider
	name = "Blight spider"
	desc = "Evolves a spider filled with a sickening venom."
	genomecost = 7
	spiderpath = /obj/item/implant/carrion_spider/blight

/datum/power/carrion/breeding_spider
	name = "Breeding spider"
	desc = "Creates a spider carrying eggs, when it will be put inside a dead host and activated, the eggs will give birth to many lesser ones of your kin."
	genomecost = 4
	spiderpath = /obj/item/implant/carrion_spider/breeding

/datum/power/carrion/explosive_spider
	name = "Explosive spider"
	desc = "Creates an expensive spider that makes a small explosion."
	genomecost = 10
	spiderpath = /obj/item/implant/carrion_spider/explosive

/datum/power/carrion/spark_spider
	name = "Spark spider"
	desc = "Creates a spider that makes a small spark."
	genomecost = 1
	spiderpath = /obj/item/implant/carrion_spider/spark

/datum/power/carrion/toxic_spider
	name = "Toxin bomb spider"
	desc = "Creates a spider filled with dangerous lexorin gas, explodes on activation."
	genomecost = 5
	spiderpath = /obj/item/implant/carrion_spider/toxicbomb

/datum/power/carrion/mindboil_spider
	name = "Mindboil spider"
	desc = "Creates a horrible spider able to drive everyone around him insane."
	helptext = "Used to complete derail contracts"
	genomecost = 5
	spiderpath = /obj/item/implant/carrion_spider/mindboil

/datum/power/carrion/talking_spider
	name = "Talking spider"
	desc = "Creates a spider that can hijack someones vocal cords, giving you the ability to talk through them."
	genomecost = 5
	spiderpath = /obj/item/implant/carrion_spider/talking

/datum/power/carrion/observer_spider
	name = "Observer spider"
	desc = "Creates a spider with a large monocular eye, useful for spying on others."
	helptext = "Used to complete recon contracts"
	genomecost = 3
	spiderpath = /obj/item/implant/carrion_spider/observer

/datum/power/carrion/identity_spider
	name = "Idenitity spider"
	desc = "Creates a spider with the ability to extract and transmit human DNA to you."
	genomecost = 3
	spiderpath = /obj/item/implant/carrion_spider/identity

/datum/power/carrion/signal_spider
	name = "Electrocurrent spider"
	desc = "Creates a spider that can pulse wires in machines."
	genomecost = 2
	spiderpath = /obj/item/implant/carrion_spider/signal

/datum/power/carrion/smooth_spider
	name = "Smooth spider"
	desc = "Evolves a spider of pure horror."
	genomecost = 3
	spiderpath = /obj/item/implant/carrion_spider/smooth

/datum/power/carrion/maw
	name = "Carrion Maw"
	desc = "Unlocks and expands your jaw, giving you the ability to spit acid, call upon spiders and tear off limbs."
	genomecost = 0
	organpath = /obj/item/organ/internal/carrion/maw

/datum/power/carrion/spinneret
	name = "Carrion Spinneret"
	desc = "Grows a spinneret inside your lower body, making you able to create a spider nest, filter your blood from all chemicals and make webs."
	genomecost = 7
	organpath = /obj/item/organ/internal/carrion/spinneret

/datum/power/carrion/chemvessel
	name = "Chemical Vessel"
	desc = "Grows a chemical vessel that stores and produces chemicals needed for your abilities."
	genomecost = 0
	organpath = /obj/item/organ/internal/carrion/chemvessel

/obj/item/organ/internal/carrion/core/proc/EvolutionMenu()	//Topic proc is stored in code\modules\organs\internal\carrion.dm
	set category = "Carrion"
	set desc = "Level up!"

	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	var/dat = "<html><head><title>Carrion Evolution Menu</title></head>"

	//javascript, the part that does most of the work
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,name,desc,helptext,power,ownsthis){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+desc+"</b></font> <BR>"

					body += "<font size='2'><font color = 'red'><b>"+helptext+"</b></font></font><BR>"

					if(!ownsthis)
					{
						body += "<a href='?src=\ref[src];P="+power+"'>Evolve</a>"
					}

					body += "</td><td align='center'>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Carrion Evolution Menu</b></font><br>
					Hover over a power to see more information<br>
					Current evolution points left to evolve with: [geneticpoints]<br>
					Absorb genomes to acquire more evolution points
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}
	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/i = 1
	for(var/datum/power/carrion/P in powerinstances)
		var/ownsthis = 0

		if(P in purchasedpowers)
			ownsthis = 1


		var/color = "#e6e6e6"
		if(i%2 == 0)
			color = "#f2f2f2"


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P]",[ownsthis])'
					>
					<span id='search[i]'><b>Evolve [P] - Cost: [ownsthis ? "Purchased" : P.genomecost]</b></span>
					</a>
					<br><span id='item[i]'></span>
				</td>
			</tr>

		"}

		i++

	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(dat, "window=powers;size=900x480")

/obj/item/organ/internal/carrion/core/proc/purchasePower(var/Pname, var/free = FALSE)
	var/datum/power/carrion/Thepower = Pname

	for (var/datum/power/carrion/P in powerinstances)
		//world << "[P] - [Pname] = [P.name == Pname ? "True" : "False"]"
		if(P.name == Pname)
			Thepower = P
			break


	if(Thepower == null)
		to_chat(owner, "This is awkward. Carrion power purchase failed, please report this bug to a coder!")
		return

	if(Thepower in purchasedpowers)
		to_chat(owner, "You have already evolved this ability!")
		return

	if(geneticpoints < Thepower.genomecost && !free)
		to_chat(owner, "You cannot evolve this... yet.  You must acquire more DNA.")
		return

	if(!free)
		geneticpoints -= Thepower.genomecost

	purchasedpowers += Thepower

	if (Thepower.organpath)
		var/obj/item/organ/internal/organ = new Thepower.organpath
		var/obj/item/organ/external/parentorgan =  owner.get_organ(organ.parent_organ_base)
		parentorgan.add_item(organ, owner, FALSE)

	if(Thepower.spiderpath)
		spiderlist |= Thepower.spiderpath
