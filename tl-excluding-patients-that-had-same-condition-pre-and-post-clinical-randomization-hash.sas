Excluding patients that had same condition pre and post clinical randomization hash

Nice exmple of a hash (no sort needed)

     Two solutions ( by Mark)

       a.  Large hash
       b.  Two hash
           Mike Keintz
           mkeintz@outlook.com

GitHub
https://tinyurl.com/dnbkyxpr
https://github.com/rogerjdeangelis/utl-excluding-patients-that-had-same-condition-pre-and-post-clinical-randomization-hash

SAS Forum
https://communities.sas.com/t5/SAS-Programming/Data-Manipulation/m-p/727266

Solution by
Mike Keintz
mkeintz@outlook.com
https://communities.sas.com/t5/user/viewprofilepage/user-id/31461

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
   input id$ type$ conditions $22.;
   put id $hex8.;
cards4;
1 Post Anemia
1 Post Colitis
1 Post Diarrhea
1 Post Neuro
1 Pre Anemia
1 Pre Diarrhea
1 Pre Myositis
1 Pre Polyneuropathy
2 Post Adrenal
2 Post Colitis
2 Post Neutropenia
3 Post Dermatitis
3 Post Myositis
3 Post Neuro
;;;;
run;quit;


/* Data sorted for explanation purposes only

proc sort data=have out=havSrt noequals;
  by id conditions;
run;quit;

WORK.HAVSRT total obs=14         | RULES
                                 |
  ID    TYPE    CONDITIONS       |

  1     Post    Anemia           | Remove this patient
  1     Pre     Anemia           |

  1     Post    Colitis          |

  1     Post    Diarrhea         |  Remove this patient
  1     Pre     Diarrhea         |

  1     Pre     Myositis         |
  1     Post    Neuro            |
  1     Pre     Polyneuropathy   |

  2     Post    Adrenal          |
  2     Post    Colitis          |
  2     Post    Neutropenia      |
  3     Post    Dermatitis       |
  3     Post    Myositis         |
  3     Post    Neuro            |

*/

*
 _ __  _ __ ___   ___ ___  ___ ___
| '_ \| '__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|        _                        _               _
  __ _    | | __ _ _ __ __ _  ___  | |__   __ _ ___| |__
 / _` |   | |/ _` | '__/ _` |/ _ \ | '_ \ / _` / __| '_ \
| (_| |_  | | (_| | | | (_| |  __/ | | | | (_| \__ \ | | |
 \__,_(_) |_|\__,_|_|  \__, |\___| |_| |_|\__,_|___/_| |_|
                       |___/
;

/* if pre check to see if in NOT IN post hash for patient
    if post check to see if in NOT IN pre hash for patient  */

data want;
  set have;
  if _n_=1 then do;
    declare hash all_conditions (dataset:'have');
      all_conditions.definekey('id','conditions','type');
      all_conditions.definedone();
  end;
  if (type='Pre' and all_conditions.check(key:id,key:conditions,key:'Post')^=0) or
     (type='Post' and all_conditions.check(key:id,key:conditions,key:'Pre')^=0) ;
run;quit;

*_        _                   _               _
| |__    | |___      _____   | |__   __ _ ___| |__
| '_ \   | __\ \ /\ / / _ \  | '_ \ / _` / __| '_ \
| |_) |  | |_ \ V  V / (_) | | | | | (_| \__ \ | | |
|_.__(_)  \__| \_/\_/ \___/  |_| |_|\__,_|___/_| |_|

;


/*
"This creates a hash object (think lookup table) for all the pre's, and a separate hash object
for all the post's.  Then for each incoming pre record, keep it only if
that id/condition doesn't appear in the post hash.  And vice versa."
*/

data want;
  set have;
  if _n_=1 then do;
    declare hash pre_conditions (dataset:'have (where=(type="Pre")');
      pre_conditions.definekey('id','conditions');
      pre_conditions.definedone();
    declare hash post_conditions (dataset:'have (where=(type="Post")');
      post_conditions.definekey('id','conditions');
      post_conditions.definedone();
  end;
  if (type='Pre' and post_conditions.check()^=0)  or
     (type='Post' and pre_conditions.check()^=0);
run;quit;

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WANT total obs=10

  ID    TYPE    CONDITIONS

  1     Post    Colitis
  1     Post    Neuro
  1     Pre     Myositis
  1     Pre     Polyneuropathy
  2     Post    Adrenal
  2     Post    Colitis
  2     Post    Neutropenia
  3     Post    Dermatitis
  3     Post    Myositis
  3     Post    Neuro



