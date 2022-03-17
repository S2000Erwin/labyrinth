Copyright 2022 Erwin Lau

Labyrinth in Stanza

Usage
=====
To compile: 1. download Stanza in labstanza.org
            2. stanza main.stanza labyrinth.stanza -o labyrinth
To play: ./labrinth (or labyrinth.exe in Windows)

This is my first attempt to use Stanza in a non-trivial coding project.

Design
======
I choose to re-implement one of my past projects Labyrinth.
It is a computerized play of a traditional board game from GMT Games.
Interested parties should check out www.gmtgames.com to look for this elegant game about War on Terror since 2001.

Stanza is a functional programming language. I find it interesting in ways that 
1. There is a class-less object system. Functions and Structures are the main components in coding.
2. Instead of passing around references/pointers to interfaces in traditional OOP, functions are the main elements in Stanza.
   Labyrinth is a game of Event Cards. These Events require lots of functions to handle. I would like to explore how to use software functions effectively to implement game Events.

A thing that occupies my mind is how to use HashTable effectively for country states in the game. I hope there is a way to write down key => value where value can be an Int, a String or yet another HashTable. And this can go recursively to an arbitrary level. It is because it was how the game state was designed.

Now I need to initialize with a Tuple to KeyValue pairs and use it to translate to HashTable. The more I use it the more I prefer to do a late conversion. i.e. stay in Tuples until someone uses it. At that time, convert to HashTable until next time the game state is changed again. (Is it a good method? I don't know. I need to learn more about Stanza to tell.)

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

March 17, 2022



