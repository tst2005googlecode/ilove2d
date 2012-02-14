/**
* Copyright (c) 2006-2010 LOVE Development Team
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
*
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
*
* 1. The origin of this software must not be misrepresented; you must not
*    claim that you wrote the original software. If you use this software
*    in a product, an acknowledgment in the product documentation would be
*    appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
*    misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
**/

// LOVE
#include "wrap_Ai.h"

// Astar
#include "stlastar.h" // See header for copyright and usage information

// STL
#include <iostream>
#include <math.h>

#define DEBUG_LISTS 0
#define DEBUG_LIST_LENGTHS_ONLY 0
#define BROKEN_CHAR 1
using namespace std;

namespace love
{
namespace ai
{
	static Ai * instance = 0;
    static int building_map[MAX_MAPSIZE]; //棋盘地图
    static int game_map[MAX_MAPSIZE];//游戏地图, 0 可以通过，1不可以通过
    static int MAP_WIDTH = 0;
    static int MAP_HEIGHT = 0;
    
    
    // map helper functions
    
    int GetMap( int x, int y )
    {
        
        if( x < 0 ||
           x >= MAP_WIDTH ||
           y < 0 ||
           y >= MAP_HEIGHT
           )
        {
            return BROKEN_CHAR;	 
        }
        
        return game_map[(y*MAP_WIDTH)+x];
    }
    
    
    
    // Definitions
    
    class MapSearchNode
    {
    public:
        unsigned int x;	 // the (x,y) positions of the node
        unsigned int y;	
        
        MapSearchNode() { x = y = 0; }
        MapSearchNode( unsigned int px, unsigned int py ) { x=px; y=py; }
        
        float GoalDistanceEstimate( MapSearchNode &nodeGoal );
        bool IsGoal( MapSearchNode &nodeGoal );
        bool GetSuccessors( AStarSearch<MapSearchNode> *astarsearch, MapSearchNode *parent_node );
        float GetCost( MapSearchNode &successor );
        bool IsSameState( MapSearchNode &rhs );
        
        void PrintNodeInfo(); 
        
        
    };
    
    bool MapSearchNode::IsSameState( MapSearchNode &rhs )
    {
        
        // same state in a maze search is simply when (x,y) are the same
        if( (x == rhs.x) &&
           (y == rhs.y) )
        {
            return true;
        }
        else
        {
            return false;
        }
        
    }
    
    void MapSearchNode::PrintNodeInfo()
    {
        cout << "Node position : (" << x << ", " << y << ")" << endl;
    }
    
    // Here's the heuristic function that estimates the distance from a Node
    // to the Goal. 
    
    float MapSearchNode::GoalDistanceEstimate( MapSearchNode &nodeGoal )
    {
        float xd = fabs(float(((float)x - (float)nodeGoal.x)));
        float yd = fabs(float(((float)y - (float)nodeGoal.y)));
        
        return xd + yd;
    }
    
    bool MapSearchNode::IsGoal( MapSearchNode &nodeGoal )
    {
        
        if( (x == nodeGoal.x) &&
           (y == nodeGoal.y) )
        {
            return true;
        }
        
        return false;
    }
    
    // This generates the successors to the given Node. It uses a helper function called
    // AddSuccessor to give the successors to the AStar class. The A* specific initialisation
    // is done for each node internally, so here you just set the state information that
    // is specific to the application
    bool MapSearchNode::GetSuccessors( AStarSearch<MapSearchNode> *astarsearch, MapSearchNode *parent_node )
    {
        
        int parent_x = -1; 
        int parent_y = -1; 
        
        if( parent_node )
        {
            parent_x = parent_node->x;
            parent_y = parent_node->y;
        }
        
        
        MapSearchNode NewNode;
        
        // push each possible move except allowing the search to go backwards
        
        if( (GetMap( x-1, y ) < BROKEN_CHAR) 
           && !((parent_x == x-1) && (parent_y == y))
           ) 
        {
            NewNode = MapSearchNode( x-1, y );
            astarsearch->AddSuccessor( NewNode );
        }	
        
        if( (GetMap( x, y-1 ) < BROKEN_CHAR) 
           && !((parent_x == x) && (parent_y == y-1))
           ) 
        {
            NewNode = MapSearchNode( x, y-1 );
            astarsearch->AddSuccessor( NewNode );
        }	
        
        if( (GetMap( x+1, y ) < BROKEN_CHAR)
           && !((parent_x == x+1) && (parent_y == y))
           ) 
        {
            NewNode = MapSearchNode( x+1, y );
            astarsearch->AddSuccessor( NewNode );
        }	
        
		
        if( (GetMap( x, y+1 ) < BROKEN_CHAR) 
           && !((parent_x == x) && (parent_y == y+1))
           )
        {
            NewNode = MapSearchNode( x, y+1 );
            astarsearch->AddSuccessor( NewNode );
        }	
        
        return true;
    }
    
    // given this node, what does it cost to move to successor. In the case
    // of our map the answer is the map terrain value at this node since that is 
    // conceptually where we're moving
    
    float MapSearchNode::GetCost( MapSearchNode &successor )
    {
        return (float) GetMap( x, y );
        
    }

    
    int w_astarinit(lua_State * L)
	{
        MAP_WIDTH = luaL_checkint( L, 1);
        MAP_HEIGHT = luaL_checkint( L, 2);
        if (MAP_WIDTH * MAP_HEIGHT > MAX_MAPSIZE)
			return luaL_error(L, "Map size must < %d, %d is too big", MAX_MAPSIZE, MAP_WIDTH * MAP_HEIGHT);
		return 0;
	}
    int w_astarsetindexdata(lua_State * L)
    {
        int index = luaL_checkint( L, 1);
        int value = luaL_checkint( L, 2);
        if(index >= MAX_MAPSIZE)
            return luaL_error(L, "out of index %d / %d", index, MAX_MAPSIZE);
        game_map[index] = value;
        return 0;
    }
    int w_astarsetdata(lua_State * L)
	{
        // 进行下面步骤前先将 table 压入栈顶 
        int nIndex = lua_gettop( L );  // 取 table 索引值 
        lua_pushnil( L );  // nil 入栈作为初始 key
        int i = 0;
        while( 0 != lua_next( L, nIndex ) ) 
        { 
            
            // 现在栈顶（-1）是 value，-2 位置是对应的 key 
            // 这里可以判断 key 是什么并且对 value 进行各种处理
            int value = luaL_checkint( L, -1);
            building_map[i] = value;
            game_map[i] =  value <=0 ? 0 : 1;
            //printf("%d\n", luaL_checkint( L, -1));
            lua_pop( L, 1 );  // 弹出 value，让 key 留在栈顶
            i++;
        } 
        // 现在栈顶是 table
        
		return 0;
	}
    
    int w_astarfindpath(lua_State * L)
	{
        int startIndex = luaL_checkint( L, 1);
        int endIndex =  luaL_checkint( L, 2);
		AStarSearch<MapSearchNode> astarsearch;
        // Create a start state
        MapSearchNode nodeStart;
        nodeStart.x = startIndex % MAP_WIDTH;
        nodeStart.y = startIndex / MAP_WIDTH; 
        
        // Define the goal state
        MapSearchNode nodeEnd;
        nodeEnd.x = endIndex % MAP_WIDTH;						
        nodeEnd.y = endIndex / MAP_WIDTH; 
        
        // Set Start and goal states
        
        //cout << "search from " << nodeStart.x << "," << nodeStart.y << " to " << 
        //nodeEnd.x << "," << nodeEnd.y ;
        
        astarsearch.SetStartAndGoalStates( nodeStart, nodeEnd );
        
        unsigned int SearchState;
        unsigned int SearchSteps = 0;
        
        do
        {
            SearchState = astarsearch.SearchStep();
            
            SearchSteps++;
            
#if DEBUG_LISTS
            
            cout << "Steps:" << SearchSteps << "\n";
            
            int len = 0;
            
            cout << "Open:\n";
            MapSearchNode *p = astarsearch.GetOpenListStart();
            while( p )
            {
                len++;
#if !DEBUG_LIST_LENGTHS_ONLY			
                ((MapSearchNode *)p)->PrintNodeInfo();
#endif
                p = astarsearch.GetOpenListNext();
                
            }
            
            cout << "Open list has " << len << " nodes\n";
            
            len = 0;
            
            cout << "Closed:\n";
            p = astarsearch.GetClosedListStart();
            while( p )
            {
                len++;
#if !DEBUG_LIST_LENGTHS_ONLY			
                p->PrintNodeInfo();
#endif			
                p = astarsearch.GetClosedListNext();
            }
            
            cout << "Closed list has " << len << " nodes\n";
#endif
            
        }
        while( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SEARCHING );
        int steps = 0;
        
        if( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SUCCEEDED )
        {
            //cout << "Search found goal state\n";
            
            MapSearchNode *node = astarsearch.GetSolutionStart();
            
#if DISPLAY_SOLUTION
            cout << "Displaying solution\n";
#endif
            
            lua_newtable(L);
            //node->PrintNodeInfo();
            lua_pushinteger(L, node->y * MAP_WIDTH + node->x);
            lua_rawseti(L, -2, steps+1);
             
            steps ++;
            
            for( ;; )
            {
                node = astarsearch.GetSolutionNext();
                
                if( !node )
                {
                    break;
                }
                
                //node->PrintNodeInfo();
                lua_pushinteger(L, node->y * MAP_WIDTH + node->x);
                lua_rawseti(L, -2, steps+1);
                 
                steps ++;
                
            };
            
            //cout << "Solution steps " << steps << endl;
            
            // Once you're done with the solution you can free the nodes up
            astarsearch.FreeSolutionNodes();
             
        }
        else if( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_FAILED ) 
        {
            cout << "Search terminated. Did not find goal state\n";
            
        }
        
        // Display the number of loops the search went through
        //cout << "SearchSteps : " << SearchSteps << "\n";
        astarsearch.EnsureMemoryFreed();
        
        return SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SUCCEEDED ? 1 :0;
	}

	 	// List of functions to wrap.
	static const luaL_Reg functions[] = {
		{"astarinit",w_astarinit},
        {"astarsetdata",w_astarsetdata},
        {"astarsetindexdata",w_astarsetindexdata},
        {"astarfindpath",w_astarfindpath},
    
		{ 0, 0 }
	};


	int luaopen_love_ai(lua_State * L)
	{
		if(instance == 0)
		{
			try
			{
				instance = new Ai();
			}
			catch(Exception & e)
			{
				return luaL_error(L, e.what());
			}
		}
		else
			instance->retain();

		WrappedModule w;
		w.module = instance;
		w.name = "ai";
		w.flags = MODULE_T;
		w.functions = functions;
		w.types = 0;

		return luax_register_module(L, w);
	}

} // ai
} // love
