-----
-- Class for the behavior tree nodes.
--
-- @author Brenden Lech

-- The class table
Node = {}

-- The possible types a node can have (NODE_TYPE.NORMAL or NODE_TYPE.CONDITIONAL)
Node.NODE_TYPE = {}
-----
-- The normal node type, which runs its function when visited
Node.NODE_TYPE.NORMAL = "normal"
-----
-- The conditional node type, which runs its function when visited only if its previous sibling
-- node failed to complete its task
Node.NODE_TYPE.CONDITIONAL = "conditional"

-----
-- The function this node will run when visited. It can take 0-2 arguments, its first argument
-- being a table, and its second argument being an error table passed in from another node that
-- failed its task. It must return a boolean value of whether it completed its task, and optionally
-- an error table containing information on why it failed its task. Convention states the error
-- table should include an entry called errorMessage containing a human-readable explanation on
-- why it failed its task.
Node.task = nil

-----
-- The arguments to this node's task function, a table. May be nil.
Node.args = nil

-----
-- This node's type
Node.type = Node.NODE_TYPE.NORMAL

-----
-- This node's child nodes, as an ordered list
Node.children = {}

-----
-- Creates a new Node object.
-- @tparam function task The function to run when this node is visited in the tree traversal.
-- It can take 0-2 arguments, its first argument being a table, and its second argument being
-- an error table passed in from another node that failed its task. It must return a boolean
-- value of whether it completed its task, and optionally an error table containing information
-- on why it failed its task. Convention states the error table should include an entry called
-- errorMessage containing a human-readable explanation on why it failed its task.
-- @tparam[opt=nil] table args The arguments for this node's task function
-- @tparam[opt=Node.NODE_TYPE.NORMAL] string nodeType The type of node this is. Can only be one of
-- the types stored in Node.NODE_TYPE. If it isn't, it reverts to the default type.
-- @treturn Node Returns the new node object or nil if illegal arguments were given
function Node:new(task, args, nodeType)

    if not task then
        return nil
    end

    o = {}
    setmetatable(o, self)
    self.__index = self

    o.children = {}
    o.task = task
    o.args = args

    o.type = nodeType
    -- Ensures a valid node type was passed in
    if o.type then

        local invalidType = true
        for k, v in pairs(Node.NODE_TYPE) do
            if (o.type == v) then
                invalidType = false
            end
        end

        if invalidType then
            o.type = nil
        end

    end

    -- Uses the default node type if nil or an invalid type was passed in
    if not o.type then
        o.type = Node.NODE_TYPE.NORMAL
    end

    return o

end

-----
-- Adds a child to this node. A node's children are ordered, and this adds it to the end of the
-- children list on the right.
-- @tparam Node child The child node to add to this object. This function does nothing if
-- child is nil.
-- @treturn Node the node added as a child
function Node:addChild(child)
    
    if child then
        self.children[#self.children + 1] = child
    end

    return child

end

-----
-- Recursively traverses the tree depth-first, starting with this node as the root. Each node runs
-- its task when visited. Conditional nodes only run their task if their previous sibling node
-- failed to complete its task. When a node fails, it may return an error table containing
-- information on its failure. This error table is passed to its next sibling node if run, or it
-- is passed upward as the recursion unwinds due to task failure. Error tables are never passed
-- downward.
-- @tparam table siblingErrorTable[opt=nil] A table containing information from this node's sibling
-- that ran previously and failed its task. Nil if no sibling node or sibling node did not fail.
-- @treturn boolean whether the tree traversal succeeded and the root node's task was completed
-- @treturn table An error table containing information about this tree's failed traversal. Nil if
-- the traversal did not fail.
function Node:runTree(siblingErrorTable)

    local previousTaskSucceeded = true
    local childrenErrorTable = nil

    -- Recursively visits all children in this subtree
    for i = 1, #self.children, 1 do

        local visitChild = false

        -- Visit this child if it's a conditional node and the previous node failed
        if self.children[i].type == Node.NODE_TYPE.CONDITIONAL and not previousTaskSucceeded then
            visitChild = true
        end

        -- Visits this child if it's a normal node and the previous node succeeded
        if self.children[i].type == Node.NODE_TYPE.NORMAL and previousTaskSucceeded then
            visitChild = true
        end

        if visitChild then
            -- Traverses the child node's tree
            previousTaskSucceeded, childrenErrorTable = self.children[i]:runTree(childrenErrorTable)
        end

    end

    -- previousTaskSucceeded now holds whether this node's children succeeded their tasks.
    -- If the children nodes failed their tasks, this node cannot complete its task and must
    -- return false
    -- childrenErrorTable now holds the failed child node's returned error table, or nil if
    -- the last child node did not fail
    if not previousTaskSucceeded then
        return false, childrenErrorTable
    end

    -- Visits this node, running its task function
    return self:visit(siblingErrorTable)

end

-----
-- Executes this node's task function.
-- @treturn boolean Returns whether the task function succeeded in completing its task
-- @treturn table A table containing information about task failure if the task failed,
-- or nil if the task succeeded
function Node:visit(errorTable)
    success, returnedErrorTable = self.task(self.args, errorTable)
    if success then
        return true
    else
        return false, returnedErrorTable
    end
end

return Node