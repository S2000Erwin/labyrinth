2022 Erwin Lau
Labyrinth in Stanza

Disclaimer
==========
This is a work-in-progress project as of now.
Labyrinth is a game published by GMT Games. www.gmtgames.com
GMT Games publishes a lot of strategic games with deep insights. This designer is merely one of their many customers.
Their games give me endless enjoyable experience.
This designer is not affiliated with GMT Games and is not claiming any copyrights of the game.
The graphic files of the game used in this project can be found in VASSAL Labyrinth module www.vassal.org

Usage
=====
To compile: 
1. download Stanza in labstanza.org
2. download SDL2 (or runtime) in libsdl.org
3. download SDL_Image 2.0 in https://www.libsdl.org/projects/SDL_image/
4. download SDL_TTF 2.0.15 from https://www.libsdl.org/projects/SDL_ttf/release/
5. Go to VASSL to download the "Labyrinth" module. (located here as if this writing: https://vassalengine.org/wiki/Module:Labyrinth:_The_War_on_Terror). Extract the images and put in a subfolder "vassalimages". Please note that .vmod file is just a .zip file. You can rename and uncompress to extract the image files. 
6. In main.stanza, modify usplayer and/or jihadistplayer to "human", "bot", "ai", or "web" ("ai" and "web" are not supported in Stanza Labyrinth) 
7. Once setup is done, in a Terminal type: 
    make
   to build. Currently only Windows is targeted. Change "makefile" to suit your system and architecture
8. To play type "./labyrinth" or "labyrinth.exe" in Windows
    

During Play
===========
Zoom
----
There are 2 ways to zoom in and out
Keyboard: Use COMMA and FULLSTOP ( ',' and '.' ) to zoom
Multigesture: Two fingers pinch in and out



Design Notes
============
This is my first attempt to use Stanza in a non-trivial coding project.
I am still exploring the features of Stanza language. Any suggestions to make the code better and in better functional programming style are welcome.  

I choose to re-implement one of my past projects Labyrinth.
It is a computerized play of a traditional board game from GMT Games.
Interested parties should check out www.gmtgames.com to look for this elegant game about War on Terror since 2001.

Stanza is a functional programming language. I find it interesting in ways that 
1. There is a class-less object system. Functions and Structures are the main components in coding.
2. Instead of passing around references/pointers to interfaces in traditional OOP, functions are the main elements in Stanza.
   Labyrinth is a game of Event Cards. These Events require lots of functions to handle. I would like to explore how to use software functions effectively to implement game Events.

One thing that occupies my mind is how to use HashTable effectively for country states in the game. I hope there is a way to write down key => value where value can be an Int, a String or yet another HashTable. And this can go recursively to an arbitrary level. It is because it was how the game state was designed.

Now I need to initialize with a Tuple to KeyValue pairs and use it to translate to HashTable. The more I use it the more I prefer to do a late conversion. i.e. stay in Tuples until someone uses it. At that time, convert to HashTable until next time the game state is changed again. (Is it a good method? I don't know. I need to learn more about Stanza to tell.)

Dynamic Data struture
---------------------
A sample of countries tuples is shown here.

    [
    "uk" => [ "name" => "uk" "govern" => "good" "recruit" => 3 ]
    "spain" => [ "name" => "spain" "govern" => "good" "schengen" => true "recruit" => 2 ]
    "france" => [ "name" => "france" "govern" => "good" "schengen" => true "recruit" => 2 ]
    "lebanon"=> ["name"=> "lebanon", "muslim"=> true, "resource"=> 1]
    "egypt"=> ["name"=> "egypt", "muslim"=> true, "resource"=> 3, "sunni"=> true]
    "sudan"=> ["name"=> "sudan", "muslim"=> true, "resource"=> 1, "oil"=> true, "sunni"=> true, "african"=> true]
    ]

To convert it to HashTable, I use

    defn to-hashtable ( t : HashTable<String,?>, kvs : Tuple<KeyValue<?,?>> ) -> False :
    for kv in kvs do :
        val k = key(kv)
        val v = value(kv)
        match(k) :
            (k : String) : 
                match(v) :
                (v : Tuple<?>) :
                    var d : HashTable<String,?> = HashTable<String,?>()
                    to-hashtable(d, v)
                    t[k] = d
                (v) : t[k] = v  

To run recursively.

There must be a better way to do this in Stanza I have not explored.

Later, I found that encapuslating the HashTable inside the struct might be a better approach.
This reduces a lot of compiler complain about Ambiguous choices of overloaded functions.

    defstruct Country :
        name  : String
        attrs : HashTable<String,?>
    
    defstruct Countries :
        c : HashTable<String,Country>

March 17, 2022

NULL Pointer
------------
0L Long type can be used as ptr<?> in lostanza

    lostanza defn call-SDL_FillRect (p : ref<Long>, rect : ref<SDL_Rect|False>, argb : ref<Int>) -> ref<Int> :
    var pRect : ptr<SDL_Rect>
    match(rect) :
        (rect : ref<SDL_Rect>) : pRect = addr!([rect])
        (rect) : pRect = 0L as ptr<SDL_Rect>
    val result = call-c SDL_FillRect(p.value, pRect, argb.value)
    return new Int{result}

There is a null defined in lostanza. Switch to using null instead of 0L -- March 23, 2022

SDL Hiccup
----------
It turns out that the built lib has the functions SDL_BlitSurface and SDL_BlitScaled missing. Luckily they are just aliases of SDL_UpperBlit and SDL_UpperBlitScaled. Work around is done in SDL2.stanza
See https://github.com/BindBC/bindbc-sdl/issues/15

[March 31, 2022]
SDL_Delay(100) is important within the SDL_PollEvent event loop

[March 23, 2022]
Optional Function Arguments
---------------------------
It looks like there is no provision for optional argument. T|False is used. In the caller side, false is needed.

Use match() to determine function call success
----------------------------------------------
Instead of checking return value, use match to filter out return of type False which indicates unsuccessful call or not-found.

All match cases must be exhausted
---------------------------------
    match(x):
        (x : String) : x
        (x) : false

where default (x) must be there in Stanza

Empty String cannot be used to check
------------------------------------
It loosk like expression likes:
    if s == "" :

does not seem to work. Use return false and match for String instead for empty String.

break(false) instead of break
-----------------------------
label<False> break:
    while true:
        ...
        break

has no effect. break(false) should be used.

Evolution of extract ()
-----------------------
extract () is one of the most used function in this game to extract different countries for the user to designate operations.
This shows the pattern matching capability of Stanza language (or FP languages in general).

The code below is the first version. An empty Vector is made and then populated by for...loop.
Even though Stanza is employed, its full power of Functional Programming is not exploited.

    defn extract (lab : Labyrinth, func : String -> True|False, candidates : Tuple<String>|False):
        val v = Vector<String>()
        match(candidates) :
            (candidates:Tuple<String>) :
                for name in candidates do :
                    if func(name):
                        if not (name is String and isMarker(lab, name, "truce") and not mayEndTruce(lab, name)):
                            add(v, name)
            (candidates):
                for country in c(countries(lab)) do:
                    label<False> continue:
                    val name = key(country)
                    if func(name):
                        if isMarker(lab, name, "truce"):
                            if not mayEndTruce(lab, name):
                                continue(false)
                        add(v, name)
        to-tuple(v)

Below is the next version using "filter", "when ... else", and immutable "val".

    defn extract (lab : Labyrinth, func : String -> True|False, candidates : Tuple<String>|False) :
        val all-countries = seq( { key(_) } c(countries(lab)) )
        val real-candidates = all-countries when candidates is False else to-seq(candidates as Tuple<String>)
        to-tuple{_} $ filter( 
            fn (name) : ( func(name) and not (isMarker(lab, name, "truce") and not mayEndTruce(lab, name)) )
            real-candidates
        )

Then there is a third version. "all-countries" is not constructed until "when candidate is False" is evaluated.

    defn extract (lab : Labyrinth, func : String -> True|False, candidates : Tuple<String>|False) :
        val real-candidates = seq( { key(_) } c(countries(lab)) ) when candidates is False else to-seq(candidates as Tuple<String>)
        to-tuple{_} $ filter( 
            fn (name) : ( func(name) and not (isMarker(lab, name, "truce") and not mayEndTruce(lab, name)) )
            real-candidates
        )

Replace "fn (name)" by curried bracket, and put real-candidates inside "filter", it becomes...

    defn extract (lab : Labyrinth, func : String -> True|False, candidates : Tuple<String>|False) :
        to-tuple{_} $ filter( 
            { val name = _ ( func(name) and not (isMarker(lab, name, "truce") and not mayEndTruce(lab, name)) ) }
            seq( { key(_) } c(countries(lab)) ) when candidates is False else to-seq(candidates as Tuple<String>)
        )

but it looks more cryptic.


Using SDL_Event Structure
-------------------------
SDL Event structures are a big union of multiple types of the structure. Currently this designer is using multiple lostanza types and Stanza structs to re-write the C structure. There are sometimes a lot of guesswork on the field lengths and architecture (32- or 64-bit). Marshalling between lostanza and Stanza for pointers, float, uint16, uint32 etc. takes a lot of time in experimentations.

Mutiple List/Seq map(ping)
--------------------------
One of the fun stuff in FP is the use of 'do' and 'map' to get rid of the loops.
As many as three (3) List and Seqable are supported.  
However, if more than 3 are needed, I have to break them down into multiple 'map' statements.
Like this...

    val size = sdl-surface-size(win-surface(gbg))
    val new-center = map( 
        {_ + _}
        map(
            {_ / to-float(_) / _ / scalar(gbg)} 
            to-list([to-float((- x)) to-float((- y))])
            to-tuple(size)
            scale(gbg)
        )
        center(gbg) 
    )

I wish there was a version to support arbitrary number of seqables. Like this...

    val new-center = map( 
      {_ / to-float(_) / _ / scalar(gbg) + _} 
      to-list([to-float((- x)) to-float((- y))])
      to-tuple(size)
      scale(gbg)
      center(gbg) 
    )

Let me know if there is a way to do this in a single shot.
