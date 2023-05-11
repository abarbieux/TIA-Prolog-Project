:- use_module(library(lists)).
:- use_module(library(isub)).
:- use_module(library(http/json)).
:- use_module(library(http/websocket)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).


% websocket
:- http_handler(root(ws),
  	http_upgrade_to_websocket(tbot,[]),
    [spawn([])]).
    

tbot(WebSocket) :-
  	ws_receive(WebSocket, Message),
  	(Message.opcode == close -> 
		true
  	;
  	choose_server(Message.data, ResponseString),
  	ws_send(WebSocket, json(ResponseString)),
  	tbot(WebSocket)
  	).

choose_server(Data, ResponseString) :-
   read_atomics(Data, [Protocol|Message]),
   (Protocol == 'Chatbot' ->
    produire_reponse(Message, L_ligne_reponse),
    write(L_ligne_reponse),
    ecrire_reponse(L_ligne_reponse),
    flatten(L_ligne_reponse, FlattenList),
    atomics_to_string(FlattenList, ' ', ResponseString)
    ;
    (Protocol == 'AI' ->
     write(Data), nl,
		 ResponseString = "AI MODE"
     ;
     true
    )
   ).


parse_json_data(Data, Game_board, Player_info, Team_decks, Selected_player) :-
  atom_json_dict(Data, Data_dict, []),
  Game_board_string = Data_dict.get('game_board'),
  read_term_from_atom(Game_board_string, Game_board, []),
  Player_info = Data_dict.get('player_information'),
  Team_decks = Data_dict.get('teams_deck'),
  atom_codes(Data_dict.get('selected_player'), Codes), atom_chars(Selected_player, Codes).


get_position_status(Game_board, [X, Y], Status) :-
  nth0(Y, Game_board, Row),
  nth0(X, Row, Status).


get_deck_card(Team_deck, Card_index, Card_value) :-
  nth0(Card_index, Team_deck, Card_value).


parse_player_info(Player_info, Team_decks, Player_name, Counter_fall, Player_position, Fall, Number, Country, Player_deck) :-
  Player_dict = Player_info.get(Player_name),
  Counter_fall = Player_dict.get('counter_fall'),
  Player_position = Player_dict.get('current_case'),
  Fall = Player_dict.get('fall'),
  Number = Player_dict.get('numero'),
  Country_temp = Player_dict.get('pays'),
  atom_codes(Country_temp, Codes), atom_chars(Country, Codes),
  Player_deck = Team_decks.get(Country).


test(Data) :-
  parse_json_data(Data, Game_board, Player_info, Team_decks, Selected_player),
  parse_player_info(Player_info, Team_decks, Selected_player, Counter_fall, Player_position, Fall, Number, Country, Player_deck),
  write('Player Name: '), write(Selected_player), nl,
  write('Counter fall: '), write(Counter_fall), nl,
  write('Player position: '), write(Player_position), nl,
  read_term_from_atom(Player_position, Position, []),
  get_position_status(Game_board, Position, Status),
  write('Status of '), write(Player_position), write(': '), write(Status), nl,
  write('Fall: '), write(Fall), nl,
  write('Number: '), write(Number), nl,
  write('Country: '), write(Country), nl,
  write('Player Deck: '), write(Player_deck), nl,
  get_deck_card(Player_deck, 0, Card_value),
  write('First card: '), write(Card_value), nl,
  minmax(Game_board, Player_info, Team_decks, Selected_player, 3, true, 0, 0, Best_card),
  write('Best card: '), write(Best_card), nl.


testit() :-
  test('{"game_board":"[[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 2, 0, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]","player_information":{"italie_1":{"name":"italie_1","current_case":"[0, 0]","pays":"italie","numero":1,"fall":false,"counter_fall":0},"italie_2":{"name":"italie_2","current_case":"[0, 0]","pays":"italie","numero":2,"fall":false,"counter_fall":0},"italie_3":{"name":"italie_3","current_case":"[0, 0]","pays":"italie","numero":3,"fall":false,"counter_fall":0},"hollande_1":{"name":"hollande_1","current_case":"[0, 0]","pays":"hollande","numero":1,"fall":false,"counter_fall":0},"hollande_2":{"name":"hollande_2","current_case":"[0, 0]","pays":"hollande","numero":2,"fall":false,"counter_fall":0},"hollande_3":{"name":"hollande_3","current_case":"[0, 0]","pays":"hollande","numero":3,"fall":false,"counter_fall":0},"belgique_1":{"name":"belgique_1","current_case":"[0, 0]","pays":"belgique","numero":1,"fall":false,"counter_fall":0},"belgique_2":{"name":"belgique_2","current_case":"[0, 0]","pays":"belgique","numero":2,"fall":false,"counter_fall":0},"belgique_3":{"name":"belgique_3","current_case":"[0, 0]","pays":"belgique","numero":3,"fall":false,"counter_fall":0},"allemagne_1":{"name":"allemagne_1","current_case":"[0, 0]","pays":"allemagne","numero":1,"fall":false,"counter_fall":0},"allemagne_2":{"name":"allemagne_2","current_case":"[0, 0]","pays":"allemagne","numero":2,"fall":false,"counter_fall":0},"allemagne_3":{"name":"allemagne_3","current_case":"[0, 0]","pays":"allemagne","numero":3,"fall":false,"counter_fall":0}},"teams_deck":{"italie":[5,9,10,2,4],"hollande":[8,7,3,3,10],"belgique":[12,5,10,10,12],"allemagne":[9,8,3,10,1]},"selected_player":"italie_1"}').


check_chance_case_y(X, Y, Game_board, Result) :-
  write('Y: '), write(Y), nl,
  length(Game_board, Board_length),
  (Y < Board_length - 1 ->
    nth0(Y, Game_board, Row),
    nth0(X, Row, Status),
    (Status == 2 ->
      Result = true
      ;
      Result = false,
      Y1 is Y + 1,
      check_chance_case_y(X, Y1, Game_board, Result)
    )
    ;
    Result = false
  ).


check_win_case(X, Y, Game_board, Result) :-
  length(Game_board, Board_length),
  (Y < Board_length - 1 ->
    nth0(Y, Game_board, Row),
    nth0(X, Row, Status),
    (Status == 3 ->
      Result = true
      ;
      Result = false,
      Y1 is Y + 1,
      check_win_case(X, Y1, Game_board, Result)
    )
    ;
    Result = false
  ).


minmax(_, _, _, _, 0, _, _, _, Best_card) :- write(Best_card), nl.
minmax(Game_board, Player_info, Team_decks, Selected_player, Dept, Maximise, Card_iterator, Best_score, Best_card) :-
  Dept > 0,
  parse_player_info(Player_info, Team_decks, Selected_player, _, Player_position, _, _, _, Player_deck),
  length(Player_deck, Deck_length),
  (Card_iterator < Deck_length - 1 ->
    get_deck_card(Player_deck, Card_iterator, Card_value),
    write(Card_iterator), write('th card: '), write(Card_value), nl,
    read_term_from_atom(Player_position, [X, Y], []),
    write('Player position: '), write('X: '), write(X), write(' Y: '), write(Y), nl,
    Possible_X is X + Card_value,
    write('Possible X: '), write(Possible_X), nl,
    check_chance_case_y(Possible_X, 0, Game_board, Result),
    write('Chance case: '), write(Result), nl,
    (Result ->
      Card_score = Card_value + 3
      ;
      check_win_case(Possible_X, 0, Game_board, Result1),
      write('Win case: '), write(Result1), nl,
      (Result1 ->
        Card_score = Card_value + 15
        ;
        Card_score = Card_value
      )
    ),
    write('Card score: '), write(Card_score), nl,
    (Maximise ->
      (Card_score > Best_score -> New_score = Card_score, New_best_card = Card_value ; New_score = Best_score, New_best_card = Best_card),
      Dept1 is Dept - 1,
      Card_iterator1 is Card_iterator + 1,
      Best_card = Card_value,
      minmax(Game_board, Player_info, Team_decks, Selected_player, Dept1, false, Card_iterator1, New_score, New_best_card)
      ;
      (Card_score < Best_score -> New_score = Card_score, New_best_card = Card_value ; New_score = Best_score, New_best_card = Best_card),
      Dept1 is Dept - 1,
      Card_iterator1 is Card_iterator + 1,
      minmax(Game_board, Player_info, Team_decks, Selected_player, Dept1, true, Card_iterator1, New_score, New_best_card)
    )
    ;
    true
  ).


/* --------------------------------------------------------------------- */
/*                                                                       */
/*        PRODUIRE_REPONSE(L_Mots,L_Lignes_reponse) :                    */
/*                                                                       */
/*        Input : une liste de mots L_Mots representant la question      */
/*                de l'utilisateur                                       */
/*        Output : une liste de liste de mots correspondant a la         */
/*                 reponse fournie par le bot                            */
/*                                                                       */
/*        NB Pour l'instant le predicat retourne dans tous les cas       */
/*            [  [je, ne, sais, pas, '.'],                               */
/*               [les, etudiants, vont, m, '\'', aider, '.'],            */
/*               ['vous le verrez !']                                    */
/*            ]                                                          */
/*                                                                       */
/*        Je ne doute pas que ce sera le cas ! Et vous souhaite autant   */
/*        d'amusement a coder le predicat que j'ai eu a ecrire           */
/*        cet enonce et ce squelette de solution !                       */
/*                                                                       */
/*        J.-M. Jacquet, janvier 2022                                    */
/*                                                                       */
/* --------------------------------------------------------------------- */


/*                      !!!    A MODIFIER   !!!                          */

produire_reponse([fin],[L1]) :-
   L1 = [merci, de, m, '\'', avoir, consulte], !.

produire_reponse(L, Rep) :-
   (checkMClef(L, Bool), Bool ->
    clause(regle_rep(_, _, _, L, Rep), Body),
    call(Body), !
   ;
   mclef(M, _), similar(L, M), % anciennement ...,member(M,L)
   clause(regle_rep(M, _, Pattern, Rep), Body),
   match_pattern(Pattern, L),
   call(Body), !).

produire_reponse(_, [L1, L2, L3]) :-
   L1 = [je, ne, sais, pas, '.'],
   L2 = [les, etudiants, vont, m, '\'', aider, '.' ],
   L3 = ['vous le verrez !'].

checkMClef([], Bool) :- Bool = false.
checkMClef([Mot|ListeMots], Bool) :-
  (
    member(Mot, ['position', 'positions', 'positio', 'pos'])
    ->
    Bool = true
    ;
    checkMClef(ListeMots, Bool)
  ).

match_pattern(Pattern,Lmots) :-
   sublist(Pattern,Lmots).

match_pattern(LPatterns,Lmots) :-
   match_pattern_dist([100|LPatterns],Lmots).

% similarité entre pattern et mot
match_pattern(Pattern,Lmots):-
    nombre_egalite(Pattern,Lmots,Egalite), Egalite > 1.

match_pattern_dist([],_).
match_pattern_dist([N,Pattern|Lpatterns],Lmots) :-
   within_dist(N,Pattern,Lmots,Lmots_rem),
   match_pattern_dist(Lpatterns,Lmots_rem).

within_dist(_,Pattern,Lmots,Lmots_rem) :-
   prefixrem(Pattern,Lmots,Lmots_rem).
within_dist(N,Pattern,[_|Lmots],Lmots_rem) :-
   N > 1, Naux is N-1,
  within_dist(Naux,Pattern,Lmots,Lmots_rem).


sublist(SL,L) :-
   prefix(SL,L), !.
sublist(SL,[_|T]) :- sublist(SL,T).

sublistrem(SL,L,Lr) :-
   prefixrem(SL,L,Lr), !.
sublistrem(SL,[_|T],Lr) :- sublistrem(SL,T,Lr).

prefixrem([],L,L).
prefixrem([H|T],[H|L],Lr) :- prefixrem(T,L,Lr).

% Donne le nombre d'éléments similaires entre 2 listes
nombre_egalite([],_,0).
nombre_egalite(_,[],0).
nombre_egalite([],[],0).
nombre_egalite([X|XS],[Y|YS],E+E2):- nombre_egalite(X,[Y|YS],E2), nombre_egalite(XS,[Y|YS],E).
nombre_egalite([X|XS],[_|YS],E+1):- nombre_egalite([X|XS],YS,E).
nombre_egalite([X|XS],[Y|YS],E+1):- similar([X|XS],Y),nombre_egalite([X|XS],YS,E).
nombre_egalite([X|XS],[Y|YS],E):- not(similar([X|XS],Y)),nombre_egalite([X|XS],YS,E).


% ----------------------------------------------------------------%

nb_coureurs(3).
nb_equipes(4).
nb_cartes(5).

cyclist_num(1).
cyclist_num(2).
cyclist_num(3).

pays(belgique).
pays(italie).
pays(hollande).
pays(allemagne).

% ----------------------------------------------------------------%

mclef(commence,10).
mclef(equipe,5).
mclef(pays,10).
mclef(bots,5).
mclef(cartes,5).
mclef(gagner,15).
mclef(maillots,15).

mclef(hollandais,5).
mclef(belges,5).
mclef(italiens,5).
mclef(allemands,5).

mclef(valeurs, 5).
mclef(paquet, 5).
mclef(vide, 5).

mclef(chance, 10).
mclef(negative, 10).

mclef(depasser, 20).

mclef(presente, 5).
mclef(but, 5).
mclef(preparer, 5).
mclef(debut, 5).
mclef(depart, 5).

mclef(premiere, 5).
mclef(dynamique, 5).
mclef(case, 5).

mclef(aspiration, 5).
mclef(chance, 5).
mclef(echange, 5).

mclef(monte, 5).
mclef(descente, 5).

mclef(classement, 5).
mclef(general, 5).
mclef(intermediaire, 5).

mclef(sprint, 5).
mclef(points, 5).
mclef(bonification, 5).

mclef(rouge, 5).
mclef(bleu, 5).
mclef(fleche, 5).


mclef(seconde, 5).
mclef(deplacer, 5).
mclef(egalite, 5).
mclef(plus, 5).
mclef(chute, 5).
mclef(arrive, 5).
mclef(tombent, 5).

mclef(carte, 5).
mclef(jaune, 5).

mclef(conseilles, 5).

mclef(belgique_1, 1).
mclef(belgique_2, 1).
mclef(belgique_3, 1).


mclef(italie_1, 1).
mclef(italie_2, 1).
mclef(italie_3, 1).


mclef(hollande_1, 1).
mclef(hollande_2, 1).
mclef(hollande_3, 1).

mclef(allemagne_1, 1).
mclef(allemagne_2, 1).
mclef(allemagne_3, 1).

mclef(position, 1).







% ----------------------------------------------------------------%

regle_rep(commence,1,
  [ qui, commence, le, jeu ],
  [  [ c, '\'', est, au, joueur, ayant, la, plus, haute, carte, secondes, de ],
    [ "commencer." ] ] ).
/* Qui commence le jeu ? */

% ----------------------------------------------------------------%

regle_rep(pays,3,
    [ [ quels ], 3, [ pays ], 5, [ participent ], 2, [ jeu ] ],
    [ [ la, belgique, l, '\'', italie, la, hollande, et, l, '\'', "allemagne." ] ]).
/* Quels pays sont les pays qui participent au jeu ?*/

% ----------------------------------------------------------------%

regle_rep(bots,3,
    [ [ quels ], 3, [ pays ], 5, [ jouent ], 2, [ bots ] ],
    [ [ la, hollande, et, l, '\'', "allemagne." ] ]).
/* Quels pays jouent les bots ?  */

% ----------------------------------------------------------------%

regle_rep(cartes,3,
    [ [ combien ], 3, [ cartes ], 5, [ possede ], 2, [ joueur ] ],
    [ [ un, joueur, possede, X, cartes, secondes, "maximum." ] ]) :-

      nb_cartes(X).
/* Combien de cartes possede un joueur au maximum ? */

% ----------------------------------------------------------------%

regle_rep(gagner,4,
    [ [ comment ], 5, [ gagner ], 5, [ jeu ] ],
    [ [ le, joueur, qui, gagne, est, celui, dont, le, temps, total, est, le, plus, "faible."],
      [ "Le", temps, total, correspond, a, la, somme, des, temps, des, differents, "coureurs." ] ]).

/* Comment peut on gagner le jeu ? */

% ----------------------------------------------------------------%

regle_rep(equipe,5,
  [ [ combien ], 3, [ coureurs ], 5, [ equipe ] ],
  [ [ chaque, equipe, compte, X, "coureurs." ] ]) :-

     nb_coureurs(X).

/* Combien de coureurs y  a t'il par equipe ? */

% -----------------------------------------------------------------%

regle_rep(maillots, 6,
    [ [ quelle ], 5, [ couleur ], 3, [ maillots ] ],
    [ [ les, belges, portent, des, maillots, "rouges." ],
      [ "Les", italiens, portent, des, maillots, "bleus." ],
      [ "Les", hollandais, portent, des, maillots, "oranges." ],
      [ "Les", allemands, portent, des, maillots, "blancs." ]
    ]).

/* quelle est la couleur des maillots ? */

% ----------------------------------------------------------------%

regle_rep(hollandais,5,
  [ [ liste ], 3, [coureurs], 2, [hollandais] ],
  [ [ "hollande_1", "hollande_2", "hollande_3" ] ]).

/* Donne moi la liste des coureurs hollandais .*/

% ----------------------------------------------------------------%

regle_rep(belges,5,
  [ [ liste ], 3, [coureurs], 2, [belges] ],
  [ [ "belgique_1", "belgique_2", "belgique_3" ] ]).

/* Donne moi la liste des coureurs belges .*/

% ----------------------------------------------------------------%

regle_rep(italiens,5,
  [ [ liste ], 3, [coureurs], 2, [ italiens ] ],
  [ [ "italie_1", "italie_2", "italie_3" ] ]).

/* Donne moi la liste des coureurs italiens . */

% ----------------------------------------------------------------%

regle_rep(allemands,5,
  [ [ liste ], 3, [coureurs], 2, [ allemands ] ],
  [ [ "allemagne_1", "allemagne_2", "allemagne_3" ] ]).

/* Donne moi la liste des coureurs allemands . */

% ----------------------------------------------------------------%

regle_rep(valeurs,5,
  [ [ quelles ], 3, [ valeurs ], 10, [ secondes ] ],
  [ [ un, nombre, entre, 1, et, "12." ] ]).

/* Quelles sont les valeurs les valeurs secondes ? */

% ----------------------------------------------------------------%

regle_rep(paquet,5,
  [ [ combien ], 3, [ cartes ], 3, [ secondes ], 10, [ paquet ] ],
  [ [ il, y, a, "96", cartes, "secondes." ],
    [ "8", fois, chaque, "carte." ] ]).

/* Combien de cartes secondes y a t'il par paquet ? */

% ----------------------------------------------------------------%

regle_rep(vide,5,
  [ [ que ], 5, [ main ], 3, [ vide ] ],
  [ [ il, faut, piocher, 5, nouvelles, "cartes." ] ]).

/* Que fait la main vide ? */

% ----------------------------------------------------------------%

regle_rep(chance,5,
  [ [ quelles ], 5, [ valeurs ], 3, [ chance ] ],
  [ [ les, valeurs, des, cartes, chance, sont, entre, -3, et, "3." ] ]).

/* Quelles sont les valeurs des cartes chance ? */

% ----------------------------------------------------------------%

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %

% les reponses sont les meme, juste la question qui change legerement %

regle_rep(negative,5,
  [ [ que ], 5, [ valeur ], 5, [ negative ] ],
  [ [ les, cartes, a, valeur, negative, signifie, que, le, coureur, doit, "reculer." ] ]).

/* Que fait une valeur negative ?*/

% ----------------------------------------------------------------%

regle_rep(negative,5,
  [ [ quoi ], 5, [ valeur ], 5, [ negative ] ],
  [ [ les, cartes, a, valeur, negative, signifie, que, le, coureur, doit, "reculer." ] ]).

/* c'est quoi une valeur negative ?*/

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %

% ----------------------------------------------------------------%

regle_rep(depasser,5,
  [ [ peut ], 5, [ depasser ], 5, [ coureur ] ],
  [ [ oui, il, est, possible, de, depasser, un, autre, coureur, ou, un, groupe, de, "coureurs." ],
    [ "On", depasse, en, prenant, le, bas, -, cote, de, la, route, si, il, arrive, a, depasser, completement,
      le, groupe, c, '\'', est-a-dire, a, se, positionner, sur, une, case, "libre." ],
    [ "Sinon", le, coureur, chute, et, entraine, le, groupe, dans, sa, "chute."]
  ]).

/* Peut on depasser un coureur ? */

% ----------------------------------------------------------------%

regle_rep(presente,5,
  [ [presente],3,[jeu] ],
  [ [le, jeu, de, societe, du, tour, de, france, se, joue, avec, des, cartes, "seconde."],
    ["En",jouant,une, carte, seconde, vous, pouvez, faire, avancer, votre, coureur, sur, le, plateau, de, "jeu."],
    ["Faite", preuve, de, tactique, pour, laisser, vos, adversaires, faire, le, travail, en, tete, de, peloton, et, prenez, de, la, vitesse, grace, au, phenomene, d, '\'', "aspiration."],
    ["Gardez", vos, meilleures, cartes, pour, lancer, un, sprint, lorsque, vous, estimez, que, vos, adversaires, n, '\'', en, sont, pas, "capables."]
  ]).

/* Presente moi le jeu */

% ----------------------------------------------------------------%


regle_rep(but,5,
  [ [but],3,[jeu] ],
  [ [dans, le, jeu, du, tour, de, france, ',', vous, participez, a, une, etape, par, equipe, de, trois, "coureurs." ],
    ["Votre", equipe, doit, tenter, d, '\'', obtenir, le, meilleur, temps, "possible."],
    ["Un", classement, est, tenu, par, joueur, et, par, "equipe." ],
    ["Le", coureur, le, plus, rapide, sur, l, '\'', ensemble, des, etapes, porte, le, maillot, "jaune."],
    ["Le", vainqueur, du, tour, est, "l'equipe", qui, obtient, le, meilleur, temps, "global." ]
  ]).

/* Donne moi le but du jeu.*/

% ----------------------------------------------------------------%
regle_rep(preparer,5,
  [ [comment],3,[preparer],3,[jeu] ],
  [ [le, joueur, qui, pioche, la, carte, seconde, la, plus, elevee, "commence."],
    ["Le", jeu, va, ensuite, vous, distribuer, vos, "cartes."],
    ["Lorsque", vous, aurez, joue, toutes, vos, cartes, vous, recevrez, 5, nouvelles, cartes, seconde, par, "coureur."]
  ]).

/* Comment preparer le jeu ? */

%----------------------------------------------------------------%

regle_rep(depart,5,
  [ [situation],3,[depart] ],
  [ [tous, les, joueurs, disposent, de, 3, coureurs, et, de, 15, cartes, "seconde."] ]).

/* C'est quoi la situation de depart ? */

%----------------------------------------------------------------%

regle_rep(debut,5,
  [ [debut],3,[partie] ],
  [ [une, fois, les, cartes, distribuees, ',', le, premier, joueur, choisit, une, de, ses, cartes, seconde, et, la, pose, sur, la,"table."],
    ["Il", deplace, son, premier, coureur, du, nombre, de, seconde, '(', '=', cases, ')', correspondant, a, la, carte, seconde, "jouee."],
    ["Vous", determinez, vous, meme, le, rythme, de, votre, "coureur."],
    ["Le", coureur, peut, se, deplacer, tout, droit, ou, en, diagonale, ',', mais, pas, sur, le, cote, '(', '=', meme, numero, de, case, ')', ni, en, "arriere."],
    ["Vous", ne, pouvez, pas, traverser, de, case, deja, "occupee.", '(', plus, d, '\'', info, en, posant, la, question, '\"', qu, '\'', est, ce, qu, '\'', une, chute, '\"', ')']
  ]).

/* comment fonctionne le debut de partie */

%----------------------------------------------------------------%

regle_rep(premiere,5,
  [ [premiere],3,[phase],3,[jeu] ],
  [ [ une, fois, que, le, premier, joueur, a, deplace, son, coureur, numero, 1, ',', les, autres, joueurs, deplacent, leur, coureur, numero, 1 ],
    ["Une" , fois, que, chaque, joueur, a, deplace, son, coureur, numero, 1, '(', dans, le, sens, des, aiguilles, d, '\'', une, montre, ')', ',', le, premier, joueur, deplace, son, coureur, numero, 2, puis, les, autres, joueurs, deplacent, leur, coureur, numero, 2, ',', et, ainsi, de, suite, jusqu, '\'', a, ce, que, chaque, joueur, ai, place, ses, coureurs, sur, le, plateau, de, jeu]
  ]).

/* que faire pour la premiere phase de jeu */


%----------------------------------------------------------------%

regle_rep(dynamique,5,
  [ [phase],3,[dynamique] ],
  [ [ une, fois, que, tous, les, coureurs, sont, place, sur, le, plateau, de, jeu, ',', la, phase, de, jeu, dynamique, "commence."],
    ["Le", coureur, de, tete, est, deplace, en, premier, ',', puis, c, '\'', est, le, tour, du, coureur, en, position, 2, ',', puis, 3, ',', puis, 4, ',', etc, jusqu, '\'', au, coureur, en, queue, de, "peloton."],
    ["Puis", on, recommence, avec, le, '(', nouveau, ')', coureur, de, tete, et, ainsi, de, "suite."]
  ]).

/* que faire pour la phase de jeu dynamique */

%----------------------------------------------------------------%
regle_rep(case,5,
  [ [numero],3,[case] ],
  [ [ un, cote, du, parcours, est, constitue, de, cases, numerotees, sur, lesquelles, les, coureurs, sont, a, l, '\'', abri, du, vent, et, avancent, plus, rapidement, ':', il, s, '\'', agit, du, cote, "prioritaire."],
    ["Le", coureur, situe, sur, le, cote, prioritaire, passe, avant, le, '(', s, ')', joueurs, situees, sur, la, case, "voisine."],
    ["Dans", les, virages, ',', les, numeros, sont, accompagnes, de, lettre, pour, faciliter, la, comprehension, de, la, decoupe, des, "cases." ]
  ]).

/* a quoi servent les numero de case */ 

%----------------------------------------------------------------%

regle_rep(aspiration,5, 
  [ [ quoi],3, [aspiration] ],
  [ [ un, coureur, profite, du, phenomene, d, '\'', aspiration, '(', et, de, la, prise, de, vitesse, qui, en, resulte, ')',lorsqu, '\'', il, est, au, sein, d, '\'', un, peloton, ou, directement, derriere, un, autre, "coureur." ],
    ["La", prise, de, vitesse, permet, d, '\'', avancer, d, '\'', une, case, de, plus, que, la, valeur, de, la, carte, jouee, si, cela, lui, permet, ensuite, de, se, positionner, derriere, ou, a, cote, d,'\'', un, autre, "coureur."],
    ["Le", coureur, de, tete, ne, peut, pas, profiter, du, pheneomene, d, '\'', aspiration, mais, il, fait, profiter, les, coureurs, qui ,le, "suivent."],
    ["La", prise, de, vitesse, n, '\'', est, pas, obligatoire, si, elle, n , '\'', est, pas, "avantageuse."]
  ]).

/* C'est quoi l'aspiration ? */

%----------------------------------------------------------------%


regle_rep(echange,5,
  [ [case],3,[echange] ],
  [ [dans, cette, version, du, jeu, ',', il, n, '\'', y, a, pas, de, carte, "echange."],
    ["Cette", explication, ne, vaut, donc, que, pour, le, jeu, de, plateau, "officiel !"],
    ["Sur", le, parcours, ',', vous, trouverez, des, cases, "echange."],
    ["Si", l, '\'', un, de, vos, coureurs, s, '\'', arrete, sur, cette, case, ',', vous, devez, vous, defausser, de, 3, cartes, seconde, et, en, piocher, 3, "nouvelle."],
    ["Si", vous, avez, moins, de, 3, cartes, en, main, a, cet, instant, ',', vous, devez, echnager, toutes, vos, cartes, "secondes.", '(', 1, ou, 2, ')']
  ]).

/* qu'est ce que les case echange ? */

%----------------------------------------------------------------%

regle_rep(chance,5,
  [ [case],3,[chance] ],
  [ [si, vous, vous, arretez, sur, une, case, chance, ',', vous, devrez, piocher, une, carte, chance, et , l, '\'', utiliser, immediatement, ',', sauf, mention, "contraire."],
    ["La", carte, chance, doit, etre, utiliser, par, le, coureur, qui, s, '\'', y, "arrete."],
    ["Un", deplacement, du, a, une, carte, chance, ne, peut , pas, provoquer, de, chute, en, "serie."],
    ["Il", est, tout, de, fois, possible, que, la, carte, deplace, le, coureur, vers, une, chute, ayant,deja, eu, lieu, ou, que, la,carte, chance, soit, destinee, a, provoquer, une, chute, en, "serie."]
  ]).

/* qu'est ce que les case chance ? */

%----------------------------------------------------------------%

regle_rep(sprint,5,
  [ [sprint],3,[intermediaire] ],
  [ [en, passant, un, sprint, intermediaire, ',', 1, ou, plusieurs, coureurs, peuvent, gagner, des, secondes, de,  "bonification." ],
    ["Ceux", '-', ci, sont, indique, au, niveau, des, sprints, "intermediaires."],
    ["Ces", seconde,'(',s,')', sont, notees, directement, sur, le, "classement."],
    ["Pour", determiner, le, classement, a, la, fin, de, la, partie,  ',', les, secondes, de, bonification, sont, retirees, du, temps, du, "coureur.",  '(', pour, plus, d, '\'', information, ',', voir, seconde, de, bonification, ')']
  ]).

/* c'est quoi un sprint intermédiaire */
%----------------------------------------------------------------%

regle_rep(monte,5, 
  [ [quoi],3,[monte] ],
  [ [en, montee, ',', les, coureurs, avancent, nettement, mois, vite, que, sur, une, etape, de, "plaine." ],
    ["Les", cases, situees, en, montee, sont, marquees, par,des,fleches, "rouge."],
    ["Pour", determiner, la, vitesse, d, '\'', un, coureur, en, montee, ',', divisez, par, deux, la, valeur, de, la, carte, jouee, et, arrondissez, au, plus, "bas."],
    ["Un", coureur, en, montee, ne, peut, pas, profiter, du, phenomene, d, '\'', "aspiration."]
  ]).

/* c'est quoi une montee */

%----------------------------------------------------------------%

regle_rep(descente,5, 
  [ [quoi],3, [descente] ],
  [ [ les, cases, situees, en, descente, sont, marquees, par, des, fleches, "bleues." ],
    ["En", descente, ',', les, regles, sont, les, memes, que, sur, une, etape, de, plaine, a, l, '\'', exception, du, phenomene, d, '\'', aspiration, ':', la, prise, de, vitesse, equivaut, alors, a , 2, secondes, au, lieu, de, 1, "seconde."],
    ["Autre", difference, importante, ':', en, utilisant, une, prise, de ,vitesse, de, 2 , secondes, ',', vous, pouvez, doubler, le, coureur, situee, devant, "vous."],
    ["Vous", pouvez, depasser, le , coureur, de, 1 , case, maximum, et , prendre, la , tete, de, la, "course."],
    ["Comme", les, etapes, de, plaines, ',', vous, n, '\'', etes, pas, oblige, d, '\'', utiliser, la, prise, de, "vitesse."],
    ["Vous", pouvez, donc, avancer, de, 1 , seconde, au, lieu, de, 2, si, cela, s, '\'', avere, plus, "avantageux."]
  ]).

/* c'est quoi une descente */

%----------------------------------------------------------------%

regle_rep(classement,5,
  [ [classement],3,[points] ],
  [ [dans, cette, version, du, jeu, ',', il, n, '\'', y, a, pas, de, carte, classement, par, "point."],
    ["Cette", explication, ne, vaut, donc, que, pour, le, jeu, de, plateau, "officiel !"],
    ["Le", classement, par, points, est, un, classement, par, "equipe." ],
    ["Vos", coureurs, peuvent, gagner, des, points, pour, votre, equipe, tout, "entiere."],
    ["A", chaque, etape, ',', en, plus, des, secondes, de, bonification, ',', vous, pouvez, gagner, des, points, en, fonction, de, la, place, d, '\'', arrivee, de, vos, coureurs, a, la, fin, de, l, '\'', "etape."],
    ["L", '\'', ordinateur, calculera, automatiquemnt, vos, points, mais, si, vous, souhaiter, verifier, les, scores, voici, la, formule, de, calcul, ':'],
    ["Total", des, points, '=' , 11, '-', position, d, '\'', arrivee, du, coureur, '(', resultat, '=', zero, si, negatif, ')', '+', points, de, bonification, "obtenus."]
  ]).

/*  c'est quoi le classement des points */


%----------------------------------------------------------------%

regle_rep(intermediaire,5,
  [ [classement],3,[intermediaire] ],
  [ [dans, cette, version, du, jeu, ',', il, n, '\'', y, a, pas, de, carte, classement, "intermediaire."],
    ["Cette", explication, ne, vaut, donc, que, pour, le, jeu, de, plateau, "officiel !"],
    [ "Le", classement, des, sprints, intermediaire, est, calcule, apres, chaque, etape, pour, determiner, le, porteur, du, maillot, "jaune."],
    ["L", '\'', equipe, la, plus, rapide, et, le, meneur, du, classement, par, "points."],
    ["Le", coureur, qui, obtient, le, meilleur, score, total, est, le, coureur, les, plus, rapide, du, classement, intermediaire, et, obtient, le, maillot, "jaune."],
    ["A", la, fin, de, la, partie, ',', le, maillot, jaune, rempotre, des, points, "supplementaires."],
    ["Si", vous, decidez,de, ne, jouer, qu, '\'', une, seul, etape, ',', il, n, '\'', y, aura, pas, de, classement, intermediaire, et, le, coureur, le, plus, rapide, remportera, directement, le, maillot, "jaune." ]
  ]).

/* c'est quoi le classement intermediaire */

%----------------------------------------------------------------%

regle_rep(general,5,
  [ [classement],3,[general] ],
  [ [dans, cette, version, du, jeu, ',', il, n, '\'', y, a, pas, de, carte, classement, "general."],
    ["Cette", explication, ne, vaut, donc, que, pour, le, jeu, de, plateau, "officiel !"],
    ["A", la, fin, de, la, derniere, etape, ',', il, faut, calcule, le, classement, "general."],
    ["En", plus, des, titres, honoriphique, pour, l, "'", equipe, et, les, coureurs, les, plus, rapides, ',', il, faut, determine, le, vainqueur, du, tour],
    ["Lors", du, classement, general, ',', tout, les, temps, sont, transformes, en, points, afin, de, designer, le, vainqueur],
    [],
    ["Comment", est, calculer, le, classement, general, '?', ':'],
    [],
    ['-',tous, les, points, du, classement, par, points ],
    ['-', 40, points, supplementaire, pour, l, '\'', equipe, ayant, realise, le, meilleur, temps, total],
    ['-', 15, points, supplementaire, pour, l, '\'', equipe, en, 2,eme, place],
    ['-', 5, points, supplementaire, pour, l, '\'', equipe, en, 3,eme, place],
    ['-', 15, points, supplemntaire, pour, le, coureur, ayant, realise, le, meilleur, temps, toalt, '(', '=', le, maillot, jaune, ')'],
    ['-', 10, point, supplemantaire, pour, le, joueur, en, 2, eme, place],
    ['-', 5, points, supplemantaire, pour, le, joueur, en, 3, eme, place]
  ]).
/*  c'est quoi le classement general ? */

%----------------------------------------------------------------%

regle_rep(bonification,5, 
  [ [secondes],3,[bonification] ],
  [ [lors, du, jeu, ',', le, joueur, obtient, des, secondes, de, bonification, lors, des, sprints, "intermediaires."],
    ["Ces", secondes, seront, decomptees, dans, le, temps, final, des, coureurs, au, classement],
    ["Exemple", ':', si, un, coureur, a, gagne, 4, secondes, de, bonification, son, temps, est, calcule, comme, suit, ':' ],
    ["Total", des,secondes, de, l, "'", etape, '-', 4, secondes, de, bonification, '-', nombre, de, case, situees, apres, la, ligne, d, "'", "arrivee." ]
    ]).

/* c'est quoi les secondes de bonification ? */

%----------------------------------------------------------------%


regle_rep(rouge,5, 
  [ [quoi],3,[fleche],2, [rouge] ],
  [ [en, montee, ",", les, coureurs, avancent, nettement, moins, vite, que, sur, une, etape, de, plaine, "."],
    ["Les", cases, situees, en, montee, sont, marquees, par, des, fleches, rouge, "."],
    ["Pour", determiner, la, vitesse, d, "'", un, coureur, en, montee, ",", on, divise, par, 2, la, valeur, de, la, carte, jouee, et, on, l, "'", arrondis, au, plus, bas,"."],
    ["On", ne, peut, pas, profiter, de, l, "'", aspiration, en, montee, "."]
  ]).
/* A quoi servent les fleches rouge ? */
%----------------------------------------------------------------%


regle_rep(bleu,5, 
  [ [quoi],3,[fleche],2, [bleu] ],
  [ [les, cases, situees, en, descente, sont, marquees, par, des, fleches, bleues, "." ],
    ["En", descente, ",", les, regles, sont, les, memes, que, sur, les, cases, classiques, "a", l, "'", exception, du, phenomene, d, "'", aspiration, ":"],
    ["-", "Premierement", ",", la, prise, de, vitesse, equivaut, alors, a, 2, secondes, au, lieu, d, "'", une, "."],
    ["-", "Deuxiemement", ",", en, utilisant, une, prise,de, vitesse, de, 2, secondes, ",", vous, pouvez, doubler, le, coureur, d, "'", une, case, maximum, et, prendre, la, tete, de, la, course, "." ],
    ["-", "Troisiemement", ",", comme, pour, les, cases, classique, vous, n, "'", etes, pas, obliger, d, "'", utiliser, la, prise, de, vitesse, et, vous, pouvez, donc, avancer, d, "'", une, seconde, au, lieu, de, deux, "."]
  ]).

/*  A quoi servent les fleches bleu ? */

%----------------------------------------------------------------%


regle_rep(fleche,5, 
  [ [quoi],3,[fleche] ],
  [ [les, fleches, rouges, et, bleues, servent, a, indiquer, si, la, case, est, une, montee, ou, une, "descente."],
    ["Pour", plus, d, "'", information, ",", vous, pouvez, me, poser, la, question, '"', "A", quoi, servent, les, fleches, bleu, "?",'"', ou, '"', "A", quoi, servent, les, fleches, rouge, "?", '"', "." ]
  ]).
 /*     A quoi servent les fleches ? */

%----------------------------------------------------------------%

 regle_rep(cartes,5, 
  [ [comment],3,[distribue], 3, [cartes] ],
  [ [au, debut, de, partie, ",", 15, cartes, "Seconde", seront, distribue, par, personne, "."]
  ]).

 /* Comment on distribue les cartes ? */
 
%----------------------------------------------------------------%





regle_rep(tombent,5, 
  [ [coureur],3,[tombent], 2, [plus] ],
  [ [si, votre, coureur, ne, tombe, plus, alors, qu, "'", il, aurait, du, ",", c, "'", est, surement, du, au, fait, qu, un, coureur, qui, a, deja, franchi, la, ligne, d, "'", arrivee, ne, peut, plus, avoir, de, chute, en, serie, "." ]
  ]).

/*  Pourquoi les coureur ne tombent plus ? */

%----------------------------------------------------------------%




regle_rep(seconde,5, 
  [ [quoi],3,[carte], 1, [seconde] ],
  [ [une, carte, seconde, est, une, carte, que, vous, recevez, en, debut, de, jeu,"."],
    ["Vous", commencez, avec,15,cartes,"."],
    ["Le", numero, indique, sur, la, carte, correspond, au, nombre, de, case, sur, lesquelles, vous, pouvez, avancer, "."]
     ]).

/*  C'est quoi une carte seconde ? */

%----------------------------------------------------------------%




regle_rep(jaune,5, 
  [ [maillot],3,[jaune] ],
  [ [ le, maillot, jaune, est, remporte, par, le, premier, joueur, qui, fini, la, course, "."],
  ["Le", maillot, jaune, est, purement, symbolique, et, n,"'", apporte, aucun, bonus, dans, cette, version, du, jeux, "."]
  ]).

/* Comment on a le maillot jaune ? */


%----------------------------------------------------------------%



regle_rep(carte,5, 
  [ [joueur],5,[plus],3,[carte] ],
  [ [lorsque, vous, n, "'", avez, plus, de, carte, "Seconde", ",", vous, ne, pouvez, plus, jouer, "."],
    ["Le", jeu, se, termine, quand, plus, personne, n,"'",a, de, carte, "."]
  ]).

/* Que se passe t'il quand un joueur n'a plus de carte ? */




%----------------------------------------------------------------%



regle_rep(arrive,5, 
  [ [ligne ],3,[arrivee] ],
  [ [lorsque, un, coureur, a, franchi, la, ligne, d, "'", arrivee, ",", il, ne, peut, plus, engendrer, de, chute, en, serie, ou, utiliser, l, "'", aspiration, "."],
    ["La", partie, se, finit, alors, a, la, fin, de, ce, tour, une, fois, que, tout, les, autres, joueurs, on, fini, de, jouer, "."]
  ]).

/*  Que se passe t'il apres qu'un joueur franchisse la ligne d'arrivee ? */

%----------------------------------------------------------------%


regle_rep(chute,5, 
  [ [quoi],3,[chute] ],
  [ [une, chute, arrive, quand, un, joueur, atterit, sur, la, case, d, "'", un, autre, joueur, "."],
    ["Les", 2, coureurs, qui, ont, provoque, la, chute, ",",  les, coureurs, avec, qui, ils, entrent, en, contact, et, les, coureurs, present, sur, une, carte ,de, meme, numero, chutent, "."],
    ["Il", faut, un, tour, au, coureur, pour, se, remettre, de, leur, chute, "." ],
    ["Pendant", ce, temps, ils, sont, sur, le, bord, de, la, route, pour, laisser, les, autres, coureurs, passer, "."]
  
  ]).
/* C'est quoi une chute ? */



%----------------------------------------------------------------%


regle_rep(egalite,5, 
  [ [egalite],5, [choix] ],
  [ [en, cas, d, "'", egalite, lors, du, choix, de, l, "'", ordre, de, passage, ",", un, tirage, sera, reorganise, pour, les, 2, personnes, concernees, "."]
  ]).




/*  Que faire si on a une egalite lors du choix de qui commence */


%----------------------------------------------------------------%

regle_rep(deplacer,5, 
  [ [deplacer],3,[coureur], 5, [occupee] ],
  [ [non, ",", c, "'", est, interdit, sauf, si, vous, n, "'", avez, pas, d, "'", autre, choix, mais, cela, provoquera, une, chute, "."] ]
).



%----------------------------------------------------------------%

regle_rep(conseilles,5, 
  [ [conseilles],2,[faire] ],
  [ [conseilCarte,;]
  ]).

/* Que me conseilles tu de faire  */

%----------------------------------------------------------------%

regle_rep(position, 1, [ [position], 2, [equipe] ], L, Args) :-
  parseRep(L, [], Args).

/* Quel est la position du cycliste 1 de l''équipe X */
/* Attention, si on met un apostrophe devant l''équipe, ça ne trouvera pas le pays car ça va append la lettre devant l''aprostrophe rendant le pays non reconnaissable ! */

parseRep([], Acc, [[getPosition|Acc]]).
parseRep([Mot|ListeMots], Acc, Args) :-
  (cyclist_num(Mot) -> string_concat("number:", Mot, NewMot), parseRep(ListeMots, [NewMot|Acc], Args))
  ; (pays(Mot) -> string_concat("country:", Mot, NewMot), parseRep(ListeMots, [NewMot|Acc], Args))
  ; parseRep(ListeMots, Acc, Args).

/*
regle_rep(fonction,5,
  [ [key],3,[key] ],
  [ [ ],
    [],
    [],
    [],
    [],
  ]).
*/







% Vérifie si 2 textes sont similaires
similar([P|Q],X):- isub(P,X,true,D), D =< 0.99, similar(Q,X).
similar([P|_],X):- isub(P,X,true,D), D > 0.99.
%----------------------------------------------------------------%





/* --------------------------------------------------------------------- */
/*                                                                       */
/*          CONVERSION D'UNE QUESTION DE L'UTILISATEUR EN                */
/*                        LISTE DE MOTS                                  */
/*                                                                       */
/* --------------------------------------------------------------------- */

% lire_question(L_Mots)

lire_question(Question, LMots) :- read_atomics(Question, LMots).



/*****************************************************************************/
% my_char_type(+Char,?Type)
%    Char is an ASCII code.
%    Type is whitespace, punctuation, numeric, alphabetic, or special.

my_char_type(46,period) :- !.
my_char_type(X,alphanumeric) :- X >= 65, X =< 90, !.
my_char_type(X,alphanumeric) :- X >= 97, X =< 123, !.
my_char_type(X,alphanumeric) :- X >= 48, X =< 57, !.
my_char_type(X,whitespace) :- X =< 32, !.
my_char_type(X,punctuation) :- X >= 33, X =< 47, !.
my_char_type(X,punctuation) :- X >= 58, X =< 64, !.
my_char_type(X,punctuation) :- X >= 91, X =< 96, !.
my_char_type(X,punctuation) :- X >= 123, X =< 126, !.
my_char_type(_,special).


/*****************************************************************************/
% lower_case(+C,?L)
%   If ASCII code C is an upper-case letter, then L is the
%   corresponding lower-case letter. Otherwise L=C.

lower_case(X,Y) :-
    X >= 65,
    X =< 90,
    Y is X + 32, !.

lower_case(X,X).


/*****************************************************************************/
% read_lc_string(-String)
%  Reads a line of input into String as a list of ASCII codes,
%  with all capital letters changed to lower case.

read_lc_string(String) :-
    get0(FirstChar),
    lower_case(FirstChar,LChar),
    read_lc_string_aux(LChar,String).

read_lc_string_aux(10,[]) :- !.  % end of line

read_lc_string_aux(-1,[]) :- !.  % end of file

read_lc_string_aux(LChar,[LChar|Rest]) :- read_lc_string(Rest).


/*****************************************************************************/
% extract_word(+String,-Rest,-Word) (final version)
%  Extracts the first Word from String; Rest is rest of String.
%  A word is a series of contiguous letters, or a series
%  of contiguous digits, or a single special character.
%  Assumes String does not begin with whitespace.

extract_word([C|Chars],Rest,[C|RestOfWord]) :-
    my_char_type(C,Type),
    extract_word_aux(Type,Chars,Rest,RestOfWord).

extract_word_aux(special,Rest,Rest,[]) :- !.
   % if Char is special, don't read more chars.

extract_word_aux(Type,[C|Chars],Rest,[C|RestOfWord]) :-
    my_char_type(C,Type), !,
    extract_word_aux(Type,Chars,Rest,RestOfWord).

extract_word_aux(_,Rest,Rest,[]).   % if previous clause did not succeed.


/*****************************************************************************/
% remove_initial_blanks(+X,?Y)
%   Removes whitespace characters from the
%   beginning of string X, giving string Y.

remove_initial_blanks([C|Chars],Result) :-
    my_char_type(C,whitespace), !,
    remove_initial_blanks(Chars,Result).

remove_initial_blanks(X,X).   % if previous clause did not succeed.


/*****************************************************************************/
% digit_value(?D,?V)
%  Where D is the ASCII code of a digit,
%  V is the corresponding number.

digit_value(48,0).
digit_value(49,1).
digit_value(50,2).
digit_value(51,3).
digit_value(52,4).
digit_value(53,5).
digit_value(54,6).
digit_value(55,7).
digit_value(56,8).
digit_value(57,9).


/*****************************************************************************/
% string_to_number(+S,-N)
%  Converts string S to the number that it
%  represents, e.g., "234" to 234.
%  Fails if S does not represent a nonnegative integer.

string_to_number(S,N) :-
    string_to_number_aux(S,0,N).

string_to_number_aux([D|Digits],ValueSoFar,Result) :-
    digit_value(D,V),
    NewValueSoFar is 10*ValueSoFar + V,
    string_to_number_aux(Digits,NewValueSoFar,Result).

string_to_number_aux([],Result,Result).


/*****************************************************************************/
% string_to_atomic(+String,-Atomic)
%  Converts String into the atom or number of
%  which it is the written representation.

string_to_atomic([C|Chars],Number) :-
    string_to_number([C|Chars],Number), !.

string_to_atomic(String,Atom) :- name(Atom,String).
  % assuming previous clause failed.


/*****************************************************************************/
% extract_atomics(+String,-ListOfAtomics) (second version)
%  Breaks String up into ListOfAtomics
%  e.g., " abc def  123 " into [abc,def,123].

extract_atomics(String,ListOfAtomics) :-
    remove_initial_blanks(String,NewString),
    extract_atomics_aux(NewString,ListOfAtomics).

extract_atomics_aux([C|Chars],[A|Atomics]) :-
    extract_word([C|Chars],Rest,Word),
    string_to_atomic(Word,A),       % <- this is the only change
    extract_atomics(Rest,Atomics).

extract_atomics_aux([],[]).


/*****************************************************************************/
% clean_string(+String,-Cleanstring)
%  removes all punctuation characters from String and return Cleanstring

clean_string([C|Chars],L) :-
    my_char_type(C,punctuation),
    clean_string(Chars,L), !.
clean_string([C|Chars],[C|L]) :-
    clean_string(Chars,L), !.
clean_string([C|[]],[]) :-
    my_char_type(C,punctuation), !.
clean_string([C|[]],[C]).


/*****************************************************************************/
% read_atomics(-ListOfAtomics)
%  Reads a line of input, removes all punctuation characters, and converts
%  it into a list of atomic terms, e.g., [this,is,an,example].

read_atomics(QuestionString, ListOfAtomics) :-
  string_codes(QuestionString, QuestionCodes),
  clean_string(QuestionCodes,Cleanstring),
  extract_atomics(Cleanstring,ListOfAtomics).



/* --------------------------------------------------------------------- */
/*                                                                       */
/*        ECRIRE_REPONSE : ecrit une suite de lignes de texte            */
/*                                                                       */
/* --------------------------------------------------------------------- */

ecrire_reponse(L) :-
   nl, write('TBot :'),
   ecrire_li_reponse(L,1,1).

% ecrire_li_reponse(Ll,M,E)
% input : Ll, liste de listes de mots (tout en minuscules)
%         M, indique si le premier caractere du premier mot de
%            la premiere ligne doit etre mis en majuscule (1 si oui, 0 si non)
%         E, indique le nombre despaces avant ce premier mot

ecrire_li_reponse([],_,_) :-
    nl.

ecrire_li_reponse([Li|Lls],Mi,Ei) :-
   ecrire_ligne(Li,Mi,Ei,Mf),
   ecrire_li_reponse(Lls,Mf,2).

% ecrire_ligne(Li,Mi,Ei,Mf)
% input : Li, liste de mots a ecrire
%         Mi, Ei booleens tels que decrits ci-dessus
% output : Mf, booleen tel que decrit ci-dessus a appliquer
%          a la ligne suivante, si elle existe

ecrire_ligne([],M,_,M) :-
   nl.

ecrire_ligne([M|L],Mi,Ei,Mf) :-
   ecrire_mot(M,Mi,Maux,Ei,Eaux),
   ecrire_ligne(L,Maux,Eaux,Mf).

% ecrire_mot(M,B1,B2,E1,E2)
% input : M, le mot a ecrire
%         B1, indique sil faut une majuscule (1 si oui, 0 si non)
%         E1, indique sil faut un espace avant le mot (1 si oui, 0 si non)
% output : B2, indique si le mot suivant prend une majuscule
%          E2, indique si le mot suivant doit etre precede dun espace

ecrire_mot('.',_,1,_,1) :-
   write('. '), !.
ecrire_mot('\'',X,X,_,0) :-
   write('\''), !.
ecrire_mot(',',X,X,E,1) :-
   espace(E), write(','), !.
ecrire_mot(M,0,0,E,1) :-
   espace(E), write(M).
ecrire_mot(M,1,0,E,1) :-
   name(M,[C|L]),
   D is C - 32,
   name(N,[D|L]),
   espace(E), write(N).

espace(0).
espace(N) :- N>0, Nn is N-1, write(' '), espace(Nn).


/* --------------------------------------------------------------------- */
/*                                                                       */
/*                            TEST DE FIN                                */
/*                                                                       */
/* --------------------------------------------------------------------- */

fin(L) :- member(fin,L).


/* --------------------------------------------------------------------- */
/*                                                                       */
/*                         BOUCLE PRINCIPALE                             */
/*                                                                       */
/* --------------------------------------------------------------------- */

tourdefrance :-

   nl, nl, nl,
   write('Bonjour, je suis TBot, le bot explicateur du Tour de France.'), nl,
   write('En quoi puis-je vous aider ?'),
   nl, nl,

   repeat,
      write('Vous : '), ttyflush,
      lire_question(L_Mots),
      produire_reponse(L_Mots,L_ligne_reponse),
      ecrire_reponse(L_ligne_reponse),
   fin(L_Mots), !.
/* --------------------------------------------------------------------- */
/*                                                                       */
/*             ACTIVATION DU PROGRAMME APRES COMPILATION                 */
/*                                                                       */
/* --------------------------------------------------------------------- */

%:- tourdefrance. /*exec pour le serveur*/

:- initialization
    http_server(http_dispatch, [port(5000)]).
