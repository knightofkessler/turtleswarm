-----
-- Class for the behavior tree nodes. The task function passed into this node must take
-- a nil or a single table as its arguments and return boolean, otherwise behavior of this
-- class is undefined.
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
-- The function this node will run when visited. May be nil.
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
-- This function must take a single table or nil as an argument, and it must return a
-- boolean value of whether it successfully completed its task.
-- @tparam[opt=nil] table args The arguments for this node's task function
-- @tparam[opt=Node.NODE_TYPE.NORMAL] string type The type of node this is. Can only be one of
-- the types stored in Node.NODE_TYPE. If it isn't, it reverts to the default type.
-- @treturn Node Returns the new node object or nil if illegal arguments were given
function Node:new(task, args, type)

    if not task then
        return nil
    end

    o = {}
    setmetatable(o, self)
    self.__index = self

    o.children = {}
    o.task = task
    o.args = args

    o.type = type
    -- Ensures a valid node type was passed in
    if o.type then

        local invalidType = true
        for i = 0, #Node.NODE_TYPE, 1 do
            if (o.type == Node.NODE_TYPE[i]) then
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
function Node:addChild(child)
    
    if child then
        self.children[#self.children + 1] = child
    end

end

-----
-- Recursively traverses the tree depth-first, starting with this node as the root. Each node runs
-- its task when visited. Conditional nodes only run their task if their previous sibling node
-- failed to complete its task.
function Node:runTree()

    local previousTaskSucceeded = true

    -- Recursively visits all children in this subtree
    for i = 0, #self.children, 1 do

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
            previousTaskSucceeded = self.children[i].runTree()
        end

    end

    -- previousTaskSucceeded now holds whether this node's children succeeded their tasks.
    -- If the children nodes failed their tasks, this node cannot complete its task and must
    -- return false
    if not previousTaskSucceeded then
        return false
    end

    -- Visits this node, running its task function
    return self.visit()

end

-----
-- Executes this node's task function.
-- @treturn boolean Returns whether the task function succeeded in completing its task
function Node:visit()
    if self.task(self.args) then
        return true
    else
        return false
    end
end

return Node