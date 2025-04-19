<!--- 
	formats text:
	paramters:
		text - input text
		variable - output variable
	replaces:
	chr(10)	<br>
	[b]		<b>
	[i]		<i>
	[u]		<u>
	[center]<center>
	[url]	<a href="[url]">[url]
	[email]	<a href="mailto:[email]">[email]
	[img]	<img src="[img]">[img]
	[quote]	<BLOCKQUOTE
	[list]	<ul>
	[*]		<li>
	colors: 
	Black,Red,Yellow,Pink,Green,Orange,Purple,Blue,Beige,Brown,Teal,Navy,Maroon,LimeGreen
	smilies:
 --->
<cfparam name="attributes.variable" default="var">
<cfparam name="attributes.showOutput" default="false">
<cfscript>
	output = attributes.text;
	output = replaceList(output, "<,>,fuck,bitch", "&lt;,&gt;,****,*****");
	output = replaceNoCase(output, "#chr(10)#", "<br>", "ALL");
	output = replaceNoCase(output, "[b]", "<b>", "ALL");
	output = replaceNoCase(output, "[/b]", "</b>", "ALL");
	output = replaceNoCase(output, "[i]", "<i>", "ALL");
	output = replaceNoCase(output, "[/i]", "</i>", "ALL");
	output = replaceNoCase(output, "[u]", "<u>", "ALL");
	output = replaceNoCase(output, "[/u]", "</u>", "ALL");
	output = replaceNoCase(output, "[center]", "<center>", "ALL");
	output = replaceNoCase(output, "[/center]", "</center>", "ALL");
	output = replaceNoCase(output, "[list]", "<ul>", "ALL");
	output = replaceNoCase(output, "[/list]", "</ul>", "ALL");
	output = replaceNoCase(output, "[*]", "<li>", "ALL");
	output = replaceNoCase(output, "[/*]", "</li>", "ALL");
	
	// colors
	// Black,Red,Yellow,Pink,Green,Orange,Purple,Blue,Beige,Brown,Teal,Navy,Maroon,LimeGreen
	output = replaceNoCase(output, "[White]", "<font color=black>", "ALL");
	output = replaceNoCase(output, "[/White]", "</font>", "ALL");	
	output = replaceNoCase(output, "[Black]", "<font color=black>", "ALL");
	output = replaceNoCase(output, "[/Black]", "</font>", "ALL");
	output = replaceNoCase(output, "[Red]", "<font color=Red>", "ALL");
	output = replaceNoCase(output, "[/Red]", "</font>", "ALL");
	output = replaceNoCase(output, "[Yellow]", "<font color=yellow>", "ALL");
	output = replaceNoCase(output, "[/Yellow]", "</font>", "ALL");
	output = replaceNoCase(output, "[Pink]", "<font color=Pink>", "ALL");
	output = replaceNoCase(output, "[/Pink]", "</font>", "ALL");
	output = replaceNoCase(output, "[Green]", "<font color=green>", "ALL");
	output = replaceNoCase(output, "[/Green]", "</font>", "ALL");
	output = replaceNoCase(output, "[Orange]", "<font color=orange>", "ALL");
	output = replaceNoCase(output, "[/Orange]", "</font>", "ALL");
	output = replaceNoCase(output, "[Purple]", "<font color=purple>", "ALL");
	output = replaceNoCase(output, "[/Purple]", "</font>", "ALL");
	output = replaceNoCase(output, "[Blue]", "<font color=blue>", "ALL");
	output = replaceNoCase(output, "[/Blue]", "</font>", "ALL");
	output = replaceNoCase(output, "[Beige]", "<font color=beige>", "ALL");
	output = replaceNoCase(output, "[/beige]", "</font>", "ALL");
	output = replaceNoCase(output, "[Brown]", "<font color=brown>", "ALL");
	output = replaceNoCase(output, "[/brown]", "</font>", "ALL");
	output = replaceNoCase(output, "[Teal]", "<font color=teal>", "ALL");
	output = replaceNoCase(output, "[/teal]", "</font>", "ALL");
	output = replaceNoCase(output, "[Navy]", "<font color=navy>", "ALL");
	output = replaceNoCase(output, "[/navy]", "</font>", "ALL");
	output = replaceNoCase(output, "[Maroon]", "<font color=maroon>", "ALL");
	output = replaceNoCase(output, "[/maroon]", "</font>", "ALL");
	output = replaceNoCase(output, "[LimeGreen]", "<font color=limegreen>", "ALL");
	output = replaceNoCase(output, "[/limegreen]", "</font>", "ALL");

	// smilies	
	output = replaceList(output, "[:)],[:D],[8D],[:I],[:P],[}:)],[;)],[:o)],[B)],[8],[:(],[8)],[:0],[:(!],[xx(],[|)],[:X],[^],[V],[?]",
		"<img src=images/icon_smile.gif>,<img src=images/icon_smile_big.gif>,<img src=images/icon_smile_cool.gif>,<img src=images/icon_smile_blush.gif>,<img src=images/icon_smile_tongue.gif>,<img src=images/icon_smile_evil.gif>,<img src=images/icon_smile_wink.gif>,<img src=images/icon_smile_clown.gif>,<img src=images/icon_smile_blackeye.gif>,<img src=images/icon_smile_8ball.gif>,<img src=images/icon_smile_sad.gif>,<img src=images/icon_smile_shy.gif>,<img src=images/icon_smile_shock.gif>,<img src=images/icon_smile_angry.gif>,<img src=images/icon_smile_dead.gif>,<img src=images/icon_smile_sleepy.gif>,<img src=images/icon_smile_kisses.gif>,<img src=images/icon_smile_approve.gif>,<img src=images/icon_smile_dissapprove.gif>,<img src=images/icon_smile_question.gif>");	

	// font sizes
	output = replaceNoCase(output, "[size1]", "<font size=1>", "ALL");
	output = replaceNoCase(output, "[/size1]", "</font>", "ALL");
	output = replaceNoCase(output, "[size2]", "<font size=2>", "ALL");
	output = replaceNoCase(output, "[/size2]", "</font>", "ALL");
	output = replaceNoCase(output, "[size3]", "<font size=3>", "ALL");
	output = replaceNoCase(output, "[/size3]", "</font>", "ALL");
	output = replaceNoCase(output, "[size4]", "<font size=4>", "ALL");
	output = replaceNoCase(output, "[/size4]", "</font>", "ALL");
	output = replaceNoCase(output, "[size5]", "<font size=5>", "ALL");
	output = replaceNoCase(output, "[/size5]", "</font>", "ALL");
	
	// image
	find = FindNoCase("[img]", output, 1);
	while (find gt 0) {
		findEnd = FindNoCase("[/img]", output, find);
		if (findEnd gt 0) {
			midText = mid(output, find+5, findEnd-find-5);
			output = replaceNoCase(output, "[img]#midText#[/img]", "<img src=#midText# border=0>", "ALL");
		}
		else break;
		find = FindNoCase("[img]", output, findEnd+1);
	}
	// email
	find = FindNoCase("[email]", output, 1);
	while (find gt 0) {
		findEnd = FindNoCase("[/email]", output, find);
		if (findEnd gt 0) {
			midText = mid(output, find+7, findEnd-find-7);
			output = replaceNoCase(output, "[email]#midText#[/email]", "<a href=""mailto:#midText#"">#midText#</a>", "ALL");
		}
		else break;
		find = FindNoCase("[email]", output, findEnd+1);
	}
	
	// url
	find = FindNoCase("[url]", output, 1);
	while (find gt 0) {
		findEnd = FindNoCase("[/url]", output, find);
		if (findEnd gt 0) {
			midText = mid(output, find+5, findEnd-find-5);
			if (left(midText, 4) is not "http")
				theURL = "http://#midText#";
			else theURL = midText;
			output = replaceNoCase(output, "[url]#midText#[/url]", "<a href=""#theURL#"" target=_blank>#theURL#</a>", "ALL");
		}
		else break;
		find = FindNoCase("[url]", output, findEnd+1);
	}
	
	// quote
	output = replacenocase(output, "[quote]", "<blockquote><font size=1><b>quote:</b><hr noshade size=1>", "ALL");
	output = replaceNoCase(output, "[/quote]", "<hr noshade size=1></font></blockquote>", "ALL");
	
	if (attributes.showOutput)
		writeOutput(output);
	else
		setVariable("caller.#attributes.variable#", output);
</cfscript> 


		
