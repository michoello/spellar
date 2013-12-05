#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <string>
#include <algorithm>
#include <cmath>
using namespace std;

// ---------------------------------------
struct trie_t: map< char, trie_t >
{
    size_t w;
    trie_t() : w(0) {}
}
glossary;

trie_t & add( trie_t & t, const string & s )
{
    t.w++;
    return !s.empty() ? add( t[ s[0] ], s.substr(1) )
                      : t['$'];
}

// ---------------------------------------
struct rambler_t
{
    string         todo;
    string         done;
    size_t         cost;
    const trie_t * road;

    rambler_t( const string & t, const string & d, size_t c, const trie_t * r )
        :  todo( t ), done( d ), cost( c ), road( r ) {}
    rambler_t() {}
};

typedef vector<rambler_t> team_t;

// ---------------------------------------
double ramb_chances( const rambler_t & a )  { return log( ( a.road->w + 1 ) * ( a.done.size() + 1 ) ) / ( 1 << a.cost ); }

bool ramb_chance_cmp ( const rambler_t & a, const rambler_t & b ) { return ramb_chances(a) > ramb_chances(b); }
bool ramb_done_cmp   ( const rambler_t & a, const rambler_t & b ) { return a.done == b.done ? a.cost < b.cost : a.done < b.done; }
bool ramb_uniq       ( const rambler_t & a, const rambler_t & b ) { return a.done == b.done; }

// ---------------------------------------
void step_forward( const rambler_t & R, team_t & team, team_t & leaders )
{
    char           next  =       R.todo[0];
    const string & todo = next ? R.todo.substr(1) : "";

    for( map<char, trie_t>::const_iterator
            it = R.road->begin(); it != R.road->end(); ++it )
    {
        const trie_t * road  = &it->second;
        char           dest  =  it->first;
        if ( next  ==  dest )
            team.push_back( rambler_t(   todo, R.done + dest,  R.cost    ,   road ));  // RAWWAY
        else
        {
            team.push_back( rambler_t(   todo, R.done + dest,  R.cost + 1,   road ));  // CHANGE
            team.push_back( rambler_t( R.todo, R.done + dest,  R.cost + 1,   road ));  // INSERT
            if ( !next && dest == '$' )
                leaders.push_back( R );                                                // FINISH
        }
    }
    if ( next )
        team.push_back(     rambler_t(   todo, R.done,         R.cost + 1, R.road ));  // DELETE
}

// ---------------------------------------
team_t spellcheck( const string & word,
                 const size_t max_cost, const size_t team_size )
{
    team_t walkers, leaders;
           walkers.push_back( rambler_t( word, "", 0, &glossary ) ); // INITIAL

    while ( !walkers.empty() )
    {
        team_t next_g;
        for( size_t i = 0; i < min( walkers.size(), team_size ); ++i )
            if ( walkers[i].cost < max_cost )
                step_forward( walkers[i], next_g, leaders );

        walkers.swap( next_g );
        sort( walkers.begin(), walkers.end(), ramb_chance_cmp );
    }

    sort( leaders.begin(), leaders.end(), ramb_done_cmp );
    leaders.resize( distance( leaders.begin(), unique( leaders.begin(), leaders.end(), ramb_uniq ) ) );
    sort( leaders.begin(), leaders.end(), ramb_chance_cmp );
    return leaders;
}

// ---------------------------------------
int main(int argc, char* argv[])
{
    ifstream fi( argv[1] );
    if ( !fi.is_open() )
        return 1;

    string word;
    while( getline( fi, word ) )
        add( glossary, word );

    while( getline( cin, word ) )
    {
        team_t leaders = spellcheck( word, word.size()/2, 512 );

        cout << word << endl;
        for( size_t i = 0; i < leaders.size(); ++i )
            cout << '\t' << leaders[i].done << ' ' << leaders[i].cost << endl;
        cout << endl;
    }

    return 0;
}
