-----
-- Tests the Node class
--
-- @author Brenden Lech

package.path = "/classes/?.lua;" .. package.path
require "Node"

-- A table used for testing how nodes run functions
testTable = {}

-----
-- A function that takes no arguments and returns true
-- @treturn boolean true
local function noArgsTrue()
    return true
end

-----
-- A function that takes no arguments and returns false
-- @treturn boolean false
local function noArgsFalse()
    return false
end

-----
-- Appends the first entry in arg to the test table and returns true
-- @tparam table arg appends the first entry in arg to the test table
-- @treturn boolean true
local function taskTrue(arg)
    testTable[#testTable + 1] = arg[1]
    return true
end

-----
-- Appends the first entry in arg to the test table and returns false
-- @tparam table arg appends the first entry in arg to the test table
-- @treturn boolean false
local function taskFalse(arg)
    testTable[#testTable + 1] = arg[1]
    return false
end

-----
-- Tests creating a new node and running its task
local function testNewNode()

    local node1 = Node:new(noArgsTrue)
    local node2 = Node:new(noArgsTrue, nil, Node.NODE_TYPE.NORMAL)
    local node3 = Node:new(noArgsTrue, nil, Node.NODE_TYPE.CONDITIONAL)
    
    local node4 = Node:new(noArgsFalse)
    local node5 = Node:new(noArgsFalse, nil, Node.NODE_TYPE.NORMAL)
    local node6 = Node:new(noArgsFalse, nil, Node.NODE_TYPE.CONDITIONAL)

    local node7 = Node:new(noArgsTrue, nil, "hello")
    local node8 = Node:new(noArgsTrue, nil, 100)

    -- Tests whether functions are passed in and run properly without arguments
    assert(node1:visit())
    assert(node2:visit())
    assert(node3:visit())
    assert(not node4:visit())
    assert(not node5:visit())
    assert(not node6:visit())
    assert(node7:visit())
    assert(node8:visit())
    
    -- Tests whether node types are passed in and error checked properly
    assert(node1.type == Node.NODE_TYPE.NORMAL)
    assert(node2.type == Node.NODE_TYPE.NORMAL)
    assert(node3.type == Node.NODE_TYPE.CONDITIONAL)
    assert(node4.type == Node.NODE_TYPE.NORMAL)
    assert(node5.type == Node.NODE_TYPE.NORMAL)
    assert(node6.type == Node.NODE_TYPE.CONDITIONAL)
    assert(node7.type == Node.NODE_TYPE.NORMAL)
    assert(node8.type == Node.NODE_TYPE.NORMAL)
    
    -- Tests whether function arguments are passed in properly
    local node101 = Node:new(taskTrue, {1})
    local node102 = Node:new(taskFalse, {2})
    local node103 = Node:new(taskTrue, {3}, Node.NODE_TYPE.NORMAL)
    local node104 = Node:new(taskFalse, {4}, Node.NODE_TYPE.NORMAL)
    local node105 = Node:new(taskTrue, {5}, Node.NODE_TYPE.CONDITIONAL)
    local node106 = Node:new(taskFalse, {6}, Node.NODE_TYPE.CONDITIONAL)
    local node107 = Node:new(taskTrue, {7}, "this is an invalid node type")
    
    -- Tests whether functions are passed in and run properly with arguments
    testTable = {}
    assert(node101:visit())
    assert(not node102:visit())
    assert(node103:visit())
    assert(not node104:visit())
    assert(node105:visit())
    assert(not node106:visit())
    assert(node107:visit())
    
    assert(testTable[1] == 1)
    assert(testTable[2] == 2)
    assert(testTable[3] == 3)
    assert(testTable[4] == 4)
    assert(testTable[5] == 5)
    assert(testTable[6] == 6)
    assert(testTable[7] == 7)

end

-----
-- Tests building and traversing trees
local function testTreeTraversal()

    -- Tests a tree with only normal nodes and a successful traversal
    local node1 = Node:new(taskTrue, {1})
    local node2 = node1:addChild(Node:new(taskTrue, {2}))
    local node3 = node1:addChild(Node:new(taskTrue, {3}))
    local node4 = node2:addChild(Node:new(taskTrue, {4}))
    local node5 = node2:addChild(Node:new(taskTrue, {5}))
    local node6 = node3:addChild(Node:new(taskTrue, {6}))
    local node7 = node3:addChild(Node:new(taskTrue, {7}))
    local node8 = node3:addChild(Node:new(taskTrue, {8}))
    local node9 = node5:addChild(Node:new(taskTrue, {9}))
    local node10 = node7:addChild(Node:new(taskTrue, {10}))
    local node11 = node7:addChild(Node:new(taskTrue, {11}))

    testTable = {}
    assert(node1:runTree())
    assert(testTable[1] == 4)
    assert(testTable[2] == 9)
    assert(testTable[3] == 5)
    assert(testTable[4] == 2)
    assert(testTable[5] == 6)
    assert(testTable[6] == 10)
    assert(testTable[7] == 11)
    assert(testTable[8] == 7)
    assert(testTable[9] == 8)
    assert(testTable[10] == 3)
    assert(testTable[11] == 1)

    -- Tests a tree with only normal nodes and a failed traversal
    node1 = Node:new(taskTrue, {1})
    node2 = node1:addChild(Node:new(taskTrue, {2}))
    node3 = node1:addChild(Node:new(taskTrue, {3}))
    node4 = node2:addChild(Node:new(taskTrue, {4}))
    node5 = node2:addChild(Node:new(taskTrue, {5}))
    node6 = node3:addChild(Node:new(taskTrue, {6}))
    node7 = node3:addChild(Node:new(taskTrue, {7}))
    node8 = node3:addChild(Node:new(taskTrue, {8}))
    node9 = node5:addChild(Node:new(taskTrue, {9}))
    node10 = node7:addChild(Node:new(taskTrue, {10}))
    node11 = node7:addChild(Node:new(taskFalse, {11}))

    testTable = {}
    assert(not node1:runTree())
    assert(testTable[1] == 4)
    assert(testTable[2] == 9)
    assert(testTable[3] == 5)
    assert(testTable[4] == 2)
    assert(testTable[5] == 6)
    assert(testTable[6] == 10)
    assert(testTable[7] == 11)
    assert(testTable[8] == nil)
    assert(testTable[9] == nil)
    assert(testTable[10] == nil)
    assert(testTable[11] == nil)

    -- Tests a tree with one conditional node that is not activated, and a successful traversal
    node1 = Node:new(taskTrue, {1})
    node2 = node1:addChild(Node:new(taskTrue, {2}))
    node3 = node1:addChild(Node:new(taskTrue, {3}))
    node4 = node2:addChild(Node:new(taskTrue, {4}))
    node5 = node2:addChild(Node:new(taskTrue, {5}))
    node6 = node3:addChild(Node:new(taskTrue, {6}))
    node7 = node3:addChild(Node:new(taskTrue, {7}, Node.NODE_TYPE.CONDITIONAL))
    node8 = node3:addChild(Node:new(taskTrue, {8}))
    node9 = node5:addChild(Node:new(taskTrue, {9}))
    node10 = node7:addChild(Node:new(taskTrue, {10}))
    node11 = node7:addChild(Node:new(taskTrue, {11}))

    testTable = {}
    assert(node1:runTree())
    assert(testTable[1] == 4)
    assert(testTable[2] == 9)
    assert(testTable[3] == 5)
    assert(testTable[4] == 2)
    assert(testTable[5] == 6)
    assert(testTable[6] == 8)
    assert(testTable[7] == 3)
    assert(testTable[8] == 1)
    assert(testTable[9] == nil)
    assert(testTable[10] == nil)
    assert(testTable[11] == nil)

    -- Tests a tree with one conditional node that is activated == and a successful traversal
    node1 = Node:new(taskTrue, {1})
    node2 = node1:addChild(Node:new(taskTrue, {2}))
    node3 = node1:addChild(Node:new(taskTrue, {3}))
    node4 = node2:addChild(Node:new(taskTrue, {4}))
    node5 = node2:addChild(Node:new(taskTrue, {5}))
    node6 = node3:addChild(Node:new(taskFalse, {6}))
    node7 = node3:addChild(Node:new(taskTrue, {7}, Node.NODE_TYPE.CONDITIONAL))
    node8 = node3:addChild(Node:new(taskTrue, {8}))
    node9 = node5:addChild(Node:new(taskTrue, {9}))
    node10 = node7:addChild(Node:new(taskTrue, {10}))
    node11 = node7:addChild(Node:new(taskTrue, {11}))

    testTable = {}
    assert(node1:runTree())
    assert(testTable[1] == 4)
    assert(testTable[2] == 9)
    assert(testTable[3] == 5)
    assert(testTable[4] == 2)
    assert(testTable[5] == 6)
    assert(testTable[6] == 10)
    assert(testTable[7] == 11)
    assert(testTable[8] == 7)
    assert(testTable[9] == 8)
    assert(testTable[10] == 3)
    assert(testTable[11] == 1)

    -- Tests a tree with one conditional node that is activated, and a failed traversal
    node1 = Node:new(taskTrue, {1})
    node2 = node1:addChild(Node:new(taskTrue, {2}))
    node3 = node1:addChild(Node:new(taskTrue, {3}))
    node4 = node2:addChild(Node:new(taskTrue, {4}))
    node5 = node2:addChild(Node:new(taskTrue, {5}))
    node6 = node3:addChild(Node:new(taskFalse, {6}))
    node7 = node3:addChild(Node:new(taskTrue, {7}, Node.NODE_TYPE.CONDITIONAL))
    node8 = node3:addChild(Node:new(taskTrue, {8}))
    node9 = node5:addChild(Node:new(taskTrue, {9}))
    node10 = node7:addChild(Node:new(taskTrue, {10}))
    node11 = node7:addChild(Node:new(taskFalse, {11}))

    testTable = {}
    assert(not node1:runTree())
    assert(testTable[1] == 4)
    assert(testTable[2] == 9)
    assert(testTable[3] == 5)
    assert(testTable[4] == 2)
    assert(testTable[5] == 6)
    assert(testTable[6] == 10)
    assert(testTable[7] == 11)
    assert(testTable[8] == nil)
    assert(testTable[9] == nil)
    assert(testTable[10] == nil)
    assert(testTable[11] == nil)

    -- Tests a more complex tree with multiple conditional nodes and a successful traversal
    node1 = Node:new(taskTrue, {1})
    node2 = node1:addChild(Node:new(taskTrue, {2}))
    node3 = node1:addChild(Node:new(taskTrue, {3}))
    node4 = node1:addChild(Node:new(taskTrue, {4}))
    node5 = node2:addChild(Node:new(taskFalse, {5}))
    node6 = node2:addChild(Node:new(taskTrue, {6}, Node.NODE_TYPE.CONDITIONAL))
    node7 = node2:addChild(Node:new(taskTrue, {7}, Node.NODE_TYPE.CONDITIONAL))
    node8 = node2:addChild(Node:new(taskTrue, {8}))
    node9 = node3:addChild(Node:new(taskTrue, {9}))
    node10 = node4:addChild(Node:new(taskTrue, {10}))
    node11 = node4:addChild(Node:new(taskTrue, {11}))
    local node12 = node5:addChild(Node:new(taskTrue, {12}))
    local node13 = node5:addChild(Node:new(taskFalse, {13}))
    local node14 = node5:addChild(Node:new(taskTrue, {14}, Node.NODE_TYPE.CONDITIONAL))
    local node15 = node6:addChild(Node:new(taskFalse, {15}))
    local node16 = node9:addChild(Node:new(taskTrue, {16}))
    local node17 = node10:addChild(Node:new(taskTrue, {17}))
    local node18 = node10:addChild(Node:new(taskTrue, {18}, Node.NODE_TYPE.CONDITIONAL))
    local node19 = node11:addChild(Node:new(taskTrue, {19}))
    local node20 = node11:addChild(Node:new(taskFalse, {20}))
    local node21 = node11:addChild(Node:new(taskTrue, {21}, Node.NODE_TYPE.CONDITIONAL))
    local node22 = node11:addChild(Node:new(taskTrue, {22}, Node.NODE_TYPE.CONDITIONAL))
    local node23 = node16:addChild(Node:new(taskTrue, {23}))
    local node24 = node16:addChild(Node:new(taskTrue, {24}))
    local node25 = node17:addChild(Node:new(taskTrue, {25}))
    local node26 = node17:addChild(Node:new(taskTrue, {26}, Node.NODE_TYPE.CONDITIONAL))
    local node27 = node18:addChild(Node:new(taskTrue, {27}))
    local node28 = node18:addChild(Node:new(taskTrue, {28}))

    testTable = {}
    assert(node1:runTree())
    assert(testTable[1] == 12)
    assert(testTable[2] == 13)
    assert(testTable[3] == 14)
    assert(testTable[4] == 5)
    assert(testTable[5] == 15)
    assert(testTable[6] == 7)
    assert(testTable[7] == 8)
    assert(testTable[8] == 2)
    assert(testTable[9] == 23)
    assert(testTable[10] == 24)
    assert(testTable[11] == 16)
    assert(testTable[12] == 9)
    assert(testTable[13] == 3)
    assert(testTable[14] == 25)
    assert(testTable[15] == 17)
    assert(testTable[16] == 10)
    assert(testTable[17] == 19)
    assert(testTable[18] == 20)
    assert(testTable[19] == 21)
    assert(testTable[20] == 11)
    assert(testTable[21] == 4)
    assert(testTable[22] == 1)
    assert(testTable[23] == nil)
    assert(testTable[24] == nil)
    assert(testTable[25] == nil)
    assert(testTable[26] == nil)
    assert(testTable[27] == nil)
    assert(testTable[28] == nil)

    -- Tests a more complex tree with multiple conditional nodes and a failed traversal
    node1 = Node:new(taskTrue, {1})
    node2 = node1:addChild(Node:new(taskTrue, {2}))
    node3 = node1:addChild(Node:new(taskTrue, {3}))
    node4 = node1:addChild(Node:new(taskTrue, {4}))
    node5 = node2:addChild(Node:new(taskFalse, {5}))
    node6 = node2:addChild(Node:new(taskTrue, {6}, Node.NODE_TYPE.CONDITIONAL))
    node7 = node2:addChild(Node:new(taskTrue, {7}, Node.NODE_TYPE.CONDITIONAL))
    node8 = node2:addChild(Node:new(taskTrue, {8}))
    node9 = node3:addChild(Node:new(taskTrue, {9}))
    node10 = node4:addChild(Node:new(taskTrue, {10}))
    node11 = node4:addChild(Node:new(taskTrue, {11}))
    node12 = node5:addChild(Node:new(taskTrue, {12}))
    node13 = node5:addChild(Node:new(taskFalse, {13}))
    node14 = node5:addChild(Node:new(taskTrue, {14}, Node.NODE_TYPE.CONDITIONAL))
    node15 = node6:addChild(Node:new(taskFalse, {15}))
    node16 = node9:addChild(Node:new(taskTrue, {16}))
    node17 = node10:addChild(Node:new(taskFalse, {17}))
    node18 = node10:addChild(Node:new(taskTrue, {18}, Node.NODE_TYPE.CONDITIONAL))
    node19 = node11:addChild(Node:new(taskTrue, {19}))
    node20 = node11:addChild(Node:new(taskFalse, {20}))
    node21 = node11:addChild(Node:new(taskTrue, {21}, Node.NODE_TYPE.CONDITIONAL))
    node22 = node11:addChild(Node:new(taskTrue, {22}, Node.NODE_TYPE.CONDITIONAL))
    node23 = node16:addChild(Node:new(taskTrue, {23}))
    node24 = node16:addChild(Node:new(taskTrue, {24}))
    node25 = node17:addChild(Node:new(taskTrue, {25}))
    node26 = node17:addChild(Node:new(taskTrue, {26}, Node.NODE_TYPE.CONDITIONAL))
    node27 = node18:addChild(Node:new(taskFalse, {27}))
    node28 = node18:addChild(Node:new(taskTrue, {28}))

    testTable = {}
    assert(not node1:runTree())
    assert(testTable[1] == 12)
    assert(testTable[2] == 13)
    assert(testTable[3] == 14)
    assert(testTable[4] == 5)
    assert(testTable[5] == 15)
    assert(testTable[6] == 7)
    assert(testTable[7] == 8)
    assert(testTable[8] == 2)
    assert(testTable[9] == 23)
    assert(testTable[10] == 24)
    assert(testTable[11] == 16)
    assert(testTable[12] == 9)
    assert(testTable[13] == 3)
    assert(testTable[14] == 25)
    assert(testTable[15] == 17)
    assert(testTable[16] == 27)
    assert(testTable[17] == nil)
    assert(testTable[18] == nil)
    assert(testTable[19] == nil)
    assert(testTable[20] == nil)
    assert(testTable[21] == nil)
    assert(testTable[22] == nil)
    assert(testTable[23] == nil)
    assert(testTable[24] == nil)
    assert(testTable[25] == nil)
    assert(testTable[26] == nil)
    assert(testTable[27] == nil)
    assert(testTable[28] == nil)
    
end

-----
-- Runs all tests
local function runTests()
    testNewNode()
    testTreeTraversal()
    io.write("All tests passed.")
end

runTests()